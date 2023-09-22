defmodule Fotohaecker.UserManagement.NoUserManagement do
  @moduledoc """
  Fallback module when no user management is enabled via config.
  """
  @behaviour Fotohaecker.UserManagement.UserManagementBehaviour
  alias Fotohaecker.UserManagement.UserManagementBehaviour

  @impl UserManagementBehaviour
  def get(_user_id) do
    {:error,
     %{
       "message" => "User management is not enabled.",
       "statusCode" => "500"
     }}
  end

  @impl UserManagementBehaviour
  def get_all do
    {:ok, []}
  end

  # @impl UserManagementBehaviour
  # def user_logs(_user_id) do
  #   {:ok, []}
  # end

  @impl UserManagementBehaviour
  def delete(_user_id) do
    {:ok, %{}}
  end

  @impl UserManagementBehaviour
  def add(_user_id) do
    {:ok, %{}}
  end

  @impl UserManagementBehaviour
  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end
end
