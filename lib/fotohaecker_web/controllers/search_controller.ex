defmodule FotohaeckerWeb.SearchController do
  use FotohaeckerWeb, :controller

  def search(conn, params) do
    search_query = params["search_query"]

    redirect(
      conn,
      to:
        Routes.search_search_path(conn, :index, Gettext.get_locale(FotohaeckerWeb.Gettext),
          search_query: search_query
        )
    )
  end
end
