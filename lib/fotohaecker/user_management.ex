defmodule Fotohaecker.UserManagement do
  @moduledoc """
  This module provides user management functionality.

  It implements the `Fotohaecker.UserManagement.UserManagementBehaviour` behaviour, which defines the interface for user management.
  """

  @behaviour Fotohaecker.UserManagement.UserManagementBehaviour
  alias Fotohaecker.UserManagement.NoUserManagement
  alias Fotohaecker.UserManagement.UserManagementBehaviour

  @impl UserManagementBehaviour
  @doc """
  Returns the user with the specified ID.
  """
  def get(id) do
    implementation().get(id)
  end

  @impl UserManagementBehaviour
  @doc """
  Returns all users.
  """
  def get_all do
    implementation().get_all()
  end

  # @impl UserManagementBehaviour
  # @doc """
  # Returns the logs for the user with the specified ID.
  # """
  # def user_logs(id) do
  #   implementation().user_logs(id)
  # end

  @impl UserManagementBehaviour
  @doc """
  Deletes the user with the specified ID.
  """
  def delete(id) do
    implementation().delete(id)
  end

  @impl UserManagementBehaviour
  @doc """
  Updates the user with the specified ID and the specified attributes.
  """
  def update(id, attributes) do
    implementation().update(id, attributes)
  end

  @impl UserManagementBehaviour
  @doc """
  Adds the user with the specified ID.
  """
  def add(id) do
    implementation().add(id)
  end

  @impl UserManagementBehaviour
  @doc """
  Starts the user management process.
  """
  def start_link(initial_value \\ []) do
    implementation().start_link(initial_value)
  end

  @impl UserManagementBehaviour
  @doc """
  Returns true if the user management is implemented.
  """
  def is_implemented?(), do: implementation() != NoUserManagement

  defp implementation,
    do:
      Application.get_env(
        :fotohaecker,
        __MODULE__,
        NoUserManagement
      )
end
