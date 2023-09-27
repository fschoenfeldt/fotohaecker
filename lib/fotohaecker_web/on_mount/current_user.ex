defmodule FotohaeckerWeb.OnMount.CurrentUser do
  @moduledoc """
  Ensures that the current user is available in the socket assigns.
  """

  def on_mount(:default, _params, %{"current_user" => user} = _session, socket) do
    {:ok, user} = Fotohaecker.UserManagement.get(user.id)
    {:cont, Phoenix.Component.assign(socket, :current_user, user)}
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont, Phoenix.Component.assign(socket, :current_user, nil)}
  end
end
