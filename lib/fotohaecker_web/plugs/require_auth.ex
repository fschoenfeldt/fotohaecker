defmodule FotohaeckerWeb.Plugs.RequireAuth do
  @moduledoc false
  # import Plug.Conn

  def init(_opts) do
    :ok
  end

  def call(conn, _opts) do
    # case Ueberauth. do
    #   {:ok, _user} ->
    #     # If the user is logged in, pass the request through unchanged
    #     conn

    #   _ ->
    #     # If the user is not logged in, redirect them to the Auth0 login page
    #     conn
    #     |> Phoenix.Controller.redirect(to: "/fh/auth/auth0")
    # end

    conn
  end
end
