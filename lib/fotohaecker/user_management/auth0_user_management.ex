defmodule Fotohaecker.UserManagement.Auth0UserManagement do
  @moduledoc """
  Implementation of the `Fotohaecker.UserManagement.UserManagementBehaviour` behaviour using Auth0.

  For a diagram, see `./auth0_user_management.md`
  """
  @behaviour Fotohaecker.UserManagement.UserManagementBehaviour
  alias Fotohaecker.UserManagement.UserManagementBehaviour
  alias Fotohaecker.UserManagement.Auth0UserManagement.Auth0Cache
  alias Fotohaecker.UserManagement.Auth0UserManagement.Auth0Management

  @impl UserManagementBehaviour
  defdelegate start_link(initial_value), to: Auth0Cache

  @impl UserManagementBehaviour
  defdelegate get(user_id), to: Auth0Cache

  @impl UserManagementBehaviour
  defdelegate get_all(), to: Auth0Cache

  @impl UserManagementBehaviour
  defdelegate add(user_id), to: Auth0Cache

  @impl UserManagementBehaviour
  defdelegate delete(user_id), to: Auth0Management

  @impl UserManagementBehaviour
  defdelegate update(user_id, attrs), to: Auth0Management

  @impl UserManagementBehaviour
  defdelegate search(query), to: Auth0Cache

  @impl UserManagementBehaviour
  defdelegate search!(query), to: Auth0Cache
end
