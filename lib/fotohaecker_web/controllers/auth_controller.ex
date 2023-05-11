defmodule FotohaeckerWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses

  Source:
  https://github.com/ueberauth/ueberauth_example/blob/master/lib/ueberauth_example_web/controllers/auth_controller.ex
  """

  use FotohaeckerWeb, :controller

  plug Ueberauth

  alias Fotohaecker.UserFromAuth
  alias Ueberauth.Strategy.Helpers

  def request(conn, params) do
    IO.inspect(Helpers.callback_url(conn))
    # IO.inspect(params)
    # IO.puts("it works!")

    # redirect(conn,
    #   to: Ueberauth.Strategy.Auth0.OAuth.authorize_url(%{scope: "openid email profile"})
    # )

    # # conn
    # # |> Auth0.authorize_url(%{scope: "openid email profile"})
    # # |> redirect()

    # conn
    # |> put_session(:callback_url, Helpers.callback_url(conn))
    # |> redirect(to: "/fh/auth/auth0/de_DE/login")
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Successfully authenticated.")
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")
    end
  end
end
