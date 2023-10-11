defmodule FotohaeckerWeb.OnMount.CurrentUser do
  @moduledoc """
  Ensures that the current user is available in the socket assigns.
  """
  require Logger

  def on_mount(:default, _params, %{"current_user" => user} = _session, socket) do
    case Fotohaecker.UserManagement.get(user.id) do
      {:ok, user} ->
        {:cont, Phoenix.Component.assign(socket, :current_user, user)}

      _other ->
        Logger.warning("OnMount.CurrentUser: session user with id #{user.id} not found.")
        {:cont, Phoenix.Component.assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont, Phoenix.Component.assign(socket, :current_user, nil)}
  end
end
