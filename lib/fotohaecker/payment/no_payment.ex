defmodule Fotohaecker.Payment.NoPayment do
  @moduledoc """
  This module implements the `Fotohaecker.Payment.PaymentBehaviour` behaviour, but does not provide any payment functionality.
  """
  @behaviour Fotohaecker.Payment.PaymentBehaviour
  alias Fotohaecker.Payment.PaymentBehaviour

  @impl PaymentBehaviour
  def create_account(_auth0_user_id) do
    {:error, %{message: "Payment is not enabled"}}
  end

  @impl PaymentBehaviour
  def delete_account(_auth0_user_id) do
    {:error, %{message: "Payment is not enabled"}}
  end

  @impl PaymentBehaviour
  def create_onboarding(_auth0_user_id) do
    {:error, %{message: "Payment is not enabled"}}
  end

  @impl PaymentBehaviour
  def retrieve(_stripe_account_id) do
    {:error, %{message: "Payment is not enabled"}}
  end

  @impl PaymentBehaviour
  def create_login_link(_stripe_account_id) do
    {:error, %{message: "Payment is not enabled"}}
  end

  @impl PaymentBehaviour
  def checkout(_auth0_user) do
    {:error, %{message: "Payment is not enabled"}}
  end

  @impl PaymentBehaviour
  def has_payment_account?(_auth0_user) do
    false
  end

  @impl PaymentBehaviour
  def payment_account_id(_auth0_user) do
    nil
  end

  @impl PaymentBehaviour
  def is_fully_onboarded?(_auth0_user) do
    false
  end
end
