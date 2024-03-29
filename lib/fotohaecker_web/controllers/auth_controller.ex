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
  alias Fotohaecker.UserManagement

  def login(conn, %{"provider" => provider, "locale" => locale} = _params) do
    conn
    |> put_session(:locale, locale)
    |> redirect(external: Helpers.auth_path(conn, :request, provider))
  end

  def logout(conn, _params) do
    locale = locale_from_session(conn)
    domain = System.get_env("AUTH0_DOMAIN")
    client_id = System.get_env("AUTH0_CLIENT_ID")

    return_to =
      conn
      |> Helpers.index_home_url(:home, locale)
      |> URI.encode_www_form()

    logout_url = "https://#{domain}/v2/logout?returnTo=#{return_to}&client_id=#{client_id}"

    conn
    |> put_flash(:info, FotohaeckerWeb.Gettext.gettext("You have been logged out!"))
    |> clear_session()
    |> redirect(external: logout_url)
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

  def delete_account(conn, _params) do
    locale = locale_from_session(conn)
    current_user = Plug.Conn.get_session(conn, :current_user)

    case UserManagement.delete(current_user.id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, gettext("Your account has been deleted!"))
        |> clear_session()
        |> redirect(to: Helpers.index_home_path(conn, :home, locale))

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Helpers.index_home_path(conn, :home, locale))
    end
  end

  # def logs(conn, _params) do
  #   locale = locale_from_session(conn)
  #   current_user = Plug.Conn.get_session(conn, :current_user)

  #   case Fotohaecker.UserManagement.logs(current_user.id) do
  #     {:ok, logs} ->
  #       conn
  #       |> put_status(200)
  #       |> json(logs)

  #     {:error, reason} ->
  #       conn
  #       |> put_flash(:error, reason)
  #       |> redirect(to: Helpers.index_home_path(conn, :home, locale))
  #   end
  # end

  defp locale_from_session(conn) do
    fallback_locale = Gettext.get_locale(FotohaeckerWeb.Gettext)

    conn
    |> get_session()
    |> Map.get("locale", fallback_locale)
  end
end
