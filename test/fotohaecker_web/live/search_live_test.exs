defmodule FotohaeckerWeb.SearchLiveTest do
  use FotohaeckerWeb.ConnCase, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint FotohaeckerWeb.Endpoint

  test "search with parameter gets no results", %{conn: conn} do
    conn = get(conn, "/fh/en_US/search?search_query=cat")
    expected = "No results found"
    actual = html_response(conn, 200)
    assert actual =~ expected
  end

  test "search with parameter gets one result", %{conn: conn} do
    _photo =
      Fotohaecker.ContentFixtures.photo_fixture(%{
        title: "Sigmund Freud"
      })

    conn = get(conn, "/fh/en_US/search?search_query=sigmund")
    expected = "go to photo Sigmund Freud on Fotohäcker"
    actual = html_response(conn, 200)
    assert actual =~ expected
  end

  test "connected mount works with no results", %{conn: conn} do
    {:ok, _view, actual} = live(conn, "/fh/en_US/search?search_query=cat")
    expected = "No results found"

    assert actual =~ expected
  end

  test "connected mount works with one result", %{conn: conn} do
    _photo =
      Fotohaecker.ContentFixtures.photo_fixture(%{
        title: "Sigmund Freud"
      })

    {:ok, _view, actual} = live(conn, "/fh/en_US/search?search_query=sigmund")
    expected = "go to photo Sigmund Freud on Fotohäcker"

    assert actual =~ expected
  end

  test "can click on search result in search", %{conn: conn} do
    _photo =
      Fotohaecker.ContentFixtures.photo_fixture(%{
        title: "Sigmund Freud"
      })

    {:ok, view, _html} = live(conn, "/fh/en_US/search?search_query=sigmund")

    {:ok, conn_new} =
      view
      |> element("#photo-1 > a")
      |> render_click()
      |> follow_redirect(conn, "/fh/en_US/photos/1")

    assert conn_new.resp_body =~ "Sigmund Freud"
  end
end
