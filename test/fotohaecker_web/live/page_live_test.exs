defmodule FotohaeckerWeb.PageLiveTest do
  use FotohaeckerWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Welcome to Fotohaecker!"
    assert render(page_live) =~ "Welcome to Fotohaecker!"
  end
end
