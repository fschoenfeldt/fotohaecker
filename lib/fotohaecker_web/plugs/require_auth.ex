defmodule FotohaeckerWeb.Plugs.RequireAuth do
  @moduledoc false
  import Plug.Conn
  import Phoenix.Controller
  alias FotohaeckerWeb.Router.Helpers, as: Routes

  def init(_opts) do
    :ok
  end

  def call(conn, _opts) do
    current_user =
      conn
      |> get_session()
      |> Map.get("current_user")

    if current_user do
      # If the user is logged in, pass the request through unchanged
      conn
    else
      # If the user is not logged in, redirect to home page
      conn
      |> put_flash(
        :error,
        "You must be logged in to access this page."
      )
      |> Phoenix.Controller.redirect(external: "https://google.com")
    end
  end
end
