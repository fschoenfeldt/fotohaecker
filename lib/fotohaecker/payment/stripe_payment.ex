defmodule Fotohaecker.Payment.StripePayment do
  @moduledoc """
  Payment within Fotohaecker.
  """
  @behaviour Fotohaecker.Payment.PaymentBehaviour
  alias Fotohaecker.Payment.PaymentBehaviour

  @doc """
  Creates a Stripe account for the given `auth0_user_id`. Puts the `auth0_user_id` in the metadata of the Stripe account.
  Also updates the auth0 user with the stripe id inside the `app_metadata`.
  """
  @impl PaymentBehaviour
  def create_account(auth0_user_id) do
    {:ok, auth0_user} = Fotohaecker.UserManagement.get(auth0_user_id)

    if has_payment_account?(auth0_user) do
      {:error, %{message: "User already has a Stripe account"}}
    else
      {:ok, stripe_account} =
        Stripe.Account.create(%{
          type: "express",
          email: auth0_user.email,
          metadata: %{
            "auth0_user_id" => auth0_user_id
          }
        })

      {:ok, _user} =
        Fotohaecker.UserManagement.update(auth0_user_id, %{
          app_metadata: %{
            stripe_id: stripe_account.id
          }
        })

      {:ok, stripe_account}
    end
  end

  @doc """
  Given an `auth0_user_id`, deletes the Stripe account associated with it. Also deletes the `stripe_id` from the `app_metadata` of the auth0 user.
  """
  @impl PaymentBehaviour
  def delete_account(auth0_user_id) do
    {:ok, auth0_user} = Fotohaecker.UserManagement.get(auth0_user_id)
    stripe_account_id = payment_account_id(auth0_user)

    case Stripe.Account.delete(stripe_account_id) do
      {:ok, deleted_account} ->
        {:ok, _user} =
          Fotohaecker.UserManagement.update(auth0_user_id, %{
            app_metadata: %{
              stripe_id: nil
            }
          })

        {:ok, deleted_account}

      error ->
        error
    end
  end

  @impl PaymentBehaviour
  def create_onboarding(auth0_user) when is_map(auth0_user),
    do:
      auth0_user
      |> payment_account_id()
      |> create_onboarding()

  def create_onboarding(stripe_account_id)
      when is_binary(stripe_account_id) do
    Stripe.AccountLink.create(%{
      account: stripe_account_id,
      refresh_url: "http://localhost:1337/fh/en_US/user",
      return_url: "http://localhost:1337/fh/en_US/user",
      type: "account_onboarding"
    })
  end

  @impl PaymentBehaviour
  def retrieve(account_id), do: Stripe.Account.retrieve(account_id)

  @impl PaymentBehaviour
  def create_login_link(account_id), do: Stripe.LoginLink.create(account_id, %{})

  @impl PaymentBehaviour
  def checkout(auth0_user) when is_map(auth0_user),
    do:
      auth0_user
      |> payment_account_id()
      |> checkout()

  # TODO: don't hardcode donation price id
  @impl PaymentBehaviour
  def checkout(
        stripe_account_id,
        price_id \\ "price_1NusQeLrossD7mFggNUhM8KQ"
      ) do
    Stripe.Session.create(%{
      success_url: "http://localhost:1337/fh/en_US/user",
      cancel_url: "http://localhost:1337/fh/en_US/user",
      mode: "payment",
      line_items: [
        %{
          price: price_id,
          quantity: 1
        }
      ],
      payment_intent_data: %{
        application_fee_amount: 123,
        transfer_data: %{
          destination: stripe_account_id
        }
      }
    })
  end

  @impl PaymentBehaviour
  def has_payment_account?(%{app_metadata: %{"stripe_id" => stripe_account_id}} = _auth0_user)
      when is_binary(stripe_account_id),
      do: true

  def has_payment_account?(_auth0_user), do: false

  @impl PaymentBehaviour
  def payment_account_id(auth0_user), do: Map.get(auth0_user.app_metadata, "stripe_id")

  @impl PaymentBehaviour
  def is_fully_onboarded?(auth0_user) do
    if has_payment_account?(auth0_user) do
      maybe_user =
        auth0_user
        |> payment_account_id()
        |> retrieve()

      case maybe_user do
        {:ok, %Stripe.Account{charges_enabled: true}} ->
          true

        _everything_else ->
          false
      end
    else
      false
    end
  end
end
