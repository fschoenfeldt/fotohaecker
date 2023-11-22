defmodule FotohaeckerWeb.SearchLiveTest do
  use FotohaeckerWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint FotohaeckerWeb.Endpoint

  setup do
    Mox.stub(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
      {:ok, []}
    end)

    on_exit(fn ->
      Application.put_env(
        :fotohaecker,
        Fotohaecker.UserManagement,
        Fotohaecker.UserManagement.UserManagementMock
      )
    end)

    :ok
  end

  describe "no results" do
    test "disconnected mount works with no results", %{conn: conn} do
      conn = get(conn, "/fh/en_US/search?search_query=cat")
      expected = "0 results"
      actual = html_response(conn, 200)
      assert actual =~ expected
    end

    test "connected mount works with no results", %{conn: conn} do
      {:ok, _view, actual} = live(conn, "/fh/en_US/search?search_query=cat")
      expected = "0 results"

      assert actual =~ expected
    end
  end

  describe "one photo result" do
    test "disconnected mount works with one result", %{conn: conn} do
      _photo =
        Fotohaecker.ContentFixtures.photo_fixture(%{
          title: "Sigmund Freud"
        })

      conn = get(conn, "/fh/en_US/search?search_query=sigmund")
      expected = "go to photo Sigmund Freud on Fotohäcker"
      actual = html_response(conn, 200)
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

  # TODO
  describe "one user result" do
    test "disconnected mount works with one result" do
      assert false
    end

    test "connected mount works with one result" do
      assert false
    end

    test "can click on search result in search" do
      assert false
    end
  end
end
