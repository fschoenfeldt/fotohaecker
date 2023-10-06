defmodule Fotohaecker.Payment do
  @moduledoc """
  This module provides payment functionality.

  It implements the `Fotohaecker.Payment.PaymentBehaviour` behaviour, which defines the interface for payment.
  """

  @behaviour Fotohaecker.Payment.PaymentBehaviour
  alias Fotohaecker.Payment.PaymentBehaviour

  @impl PaymentBehaviour
  def create_account(auth0_user_id), do: implementation().create_account(auth0_user_id)

  @impl PaymentBehaviour
  def delete_account(auth0_user_id), do: implementation().delete_account(auth0_user_id)

  @impl PaymentBehaviour
  def create_onboarding(auth0_user_or_id),
    do: implementation().create_onboarding(auth0_user_or_id)

  @impl PaymentBehaviour
  def retrieve(stripe_account_id), do: implementation().retrieve(stripe_account_id)

  @impl PaymentBehaviour
  def create_login_link(stripe_account_id),
    do: implementation().create_login_link(stripe_account_id)

  @impl PaymentBehaviour
  def checkout(auth0_user_or_id), do: implementation().checkout(auth0_user_or_id)

  @impl PaymentBehaviour
  def has_payment_account?(auth0_user_or_id),
    do: implementation().has_payment_account?(auth0_user_or_id)

  @impl PaymentBehaviour
  def payment_account_id(auth0_user_or_id),
    do: implementation().payment_account_id(auth0_user_or_id)

  @impl PaymentBehaviour
  def is_fully_onboarded?(auth0_user_or_id),
    do: implementation().is_fully_onboarded?(auth0_user_or_id)

  # TODO: fallback to default implementation
  defp implementation,
    do:
      Application.get_env(:fotohaecker, __MODULE__) ||
        raise("No implementation for #{__MODULE__}")
end
