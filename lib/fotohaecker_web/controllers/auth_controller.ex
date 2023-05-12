defmodule FotohaeckerWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses

  Source:
  https://github.com/ueberauth/ueberauth_example/blob/master/lib/ueberauth_example_web/controllers/auth_controller.ex
  """

  use FotohaeckerWeb, :controller

  plug(Ueberauth)

  alias Fotohaecker.UserFromAuth
  alias FotohaeckerWeb.Router.Helpers

  def login(conn, %{"provider" => provider, "locale" => locale} = _params) do
    conn
    |> put_session(:locale, locale)
    |> redirect(external: Helpers.auth_path(conn, :request, provider))
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, FotohaeckerWeb.Gettext.gettext("You have been logged out!"))
    |> clear_session()
    |> redirect(to: "/fh")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    locale = locale_from_session(conn)

    conn
    |> put_flash(:error, FotohaeckerWeb.Gettext.gettext("Failed to authenticate."))
    |> redirect(to: Helpers.index_home_path(conn, :home, locale))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    locale = locale_from_session(conn)

    case UserFromAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, FotohaeckerWeb.Gettext.gettext("Successfully authenticated."))
        |> put_session(:current_user, user)
        |> configure_session(renew: true)
        |> assign(:current_user, user)
        |> redirect(to: Helpers.index_home_path(conn, :home, locale))

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Helpers.index_home_path(conn, :home, locale))
    end
  end

  defp locale_from_session(conn) do
    conn |> get_session() |> Map.get("locale", Gettext.get_locale(FotohaeckerWeb.Gettext))
  end
end
