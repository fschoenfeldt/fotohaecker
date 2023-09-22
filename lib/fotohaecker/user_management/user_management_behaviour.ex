defmodule Fotohaecker.UserManagement.UserManagementBehaviour do
  @moduledoc """
  Behaviour for user management.
  """

  @callback start_link(map()) :: {:ok, pid()} | {:error, term()}
  @callback get_all() :: {:ok, [map()]} | {:error, term()}
  @callback get(id :: String.t()) :: {:ok, map()} | {:error, term()}
  @callback add(id :: String.t()) :: {:ok, map()} | {:error, term()}
  @callback delete(id :: String.t()) :: {:ok, map()} | {:error, term()}
end
