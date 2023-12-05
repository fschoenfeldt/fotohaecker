defmodule Fotohaecker.UserManagement.UserManagementBehaviour do
  @moduledoc """
  Behaviour for user management.
  """

  @type id :: String.t()

  @callback start_link(id()) :: {:ok, pid()} | {:error, term()}
  @callback get_all() :: {:ok, [map()]} | {:error, term()}
  @callback get(id()) :: {:ok, map()} | {:error, term()}
  @callback add(id()) :: {:ok, map()} | {:error, term()}
  @callback delete(id()) :: {:ok, map()} | {:error, term()}
  @callback update(id(), map()) :: {:ok, map()} | {:error, term()}
  @callback search!(String.t()) :: [map()]
  @callback search(String.t()) :: {:ok, [map()]} | {:error, term()}

  @optional_callbacks is_implemented?: 0
  @callback is_implemented?() :: boolean()
end
