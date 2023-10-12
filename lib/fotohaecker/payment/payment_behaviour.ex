defmodule Fotohaecker.Payment.PaymentBehaviour do
  @moduledoc """
  Behaviour for payment.
  """

  @type auth0_user_id :: String.t()
  @type auth0_user :: map()
  @type stripe_account_id :: String.t()
  @type error :: map()
  @type account :: map()
  @type account_link :: map()
  @type login_link :: map()
  @type session :: map()

  @callback create_account(auth0_user_id()) ::
              {:ok, account} | {:error, error}
  @callback delete_account(auth0_user_id()) ::
              {:ok, account} | {:error, error}
  @callback create_onboarding(map() | auth0_user_id()) ::
              {:ok, account_link()} | {:error, error}
  @callback retrieve(stripe_account_id()) ::
              {:ok, account} | {:error, error}
  @callback create_login_link(stripe_account_id()) ::
              {:ok, login_link()} | {:error, error}
  @callback checkout(auth0_user() | stripe_account_id()) ::
              {:ok, session()} | {:error, error}
  @callback has_payment_account?(auth0_user()) :: boolean()
  @callback payment_account_id(auth0_user()) :: String.t() | nil
  @callback is_fully_onboarded?(auth0_user()) :: boolean()

  @optional_callbacks is_implemented?: 0
  @callback is_implemented?() :: boolean()
end
