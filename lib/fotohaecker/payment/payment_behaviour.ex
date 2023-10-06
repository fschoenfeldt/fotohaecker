defmodule Fotohaecker.Payment.PaymentBehaviour do
  @moduledoc """
  Behaviour for payment.
  """

  @type auth0_user_id :: String.t()
  @type auth0_user :: map()
  @type stripe_account_id :: String.t()

  @callback create_account(auth0_user_id()) ::
              {:ok, Stripe.Account.t()} | {:error, Stripe.Error.t()}
  @callback delete_account(auth0_user_id()) ::
              {:ok, Stripe.Account.t()} | {:error, Stripe.Error.t()}
  @callback create_onboarding(map() | auth0_user_id()) ::
              {:ok, Stripe.AccountLink.t()} | {:error, Stripe.Error.t()}
  @callback retrieve(stripe_account_id()) ::
              {:ok, Stripe.Account.t()} | {:error, Stripe.Error.t()}
  @callback create_login_link(stripe_account_id()) ::
              {:ok, Stripe.LoginLink.t()} | {:error, Stripe.Error.t()}
  @callback checkout(auth0_user() | stripe_account_id()) ::
              {:ok, Stripe.Session.t()} | {:error, Stripe.Error.t()}
  @callback has_payment_account?(auth0_user()) :: boolean()
  @callback payment_account_id(auth0_user()) :: String.t() | nil
  @callback is_fully_onboarded?(auth0_user()) :: boolean()
end
