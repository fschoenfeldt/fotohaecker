defmodule FotohaeckerWeb.PageController do
  use FotohaeckerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
