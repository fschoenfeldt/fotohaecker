defmodule FotohaeckerWeb.PageController do
  use FotohaeckerWeb, :controller

  import FotohaeckerWeb.AuthController, only: [locale_from_session: 1]

  alias FotohaeckerWeb.Router.Helpers

  def index(conn, _params) do
    render(conn, "index.html")
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
end
