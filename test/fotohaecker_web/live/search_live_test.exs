defmodule FotohaeckerWeb.SearchLiveTest do
  use FotohaeckerWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint FotohaeckerWeb.Endpoint

  setup do
    Mox.stub(Fotohaecker.UserManagement.UserManagementMock, :search!, fn _term ->
      []
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
          title: "my great photo"
        })

      conn = get(conn, "/fh/en_US/search?search_query=great")
      expected = "go to photo my great photo on Fotohäcker"
      actual = html_response(conn, 200)
      assert actual =~ expected
    end

    test "connected mount works with one result", %{conn: conn} do
      _photo =
        Fotohaecker.ContentFixtures.photo_fixture(%{
          title: "my great photo"
        })

      {:ok, _view, actual} = live(conn, "/fh/en_US/search?search_query=great")
      expected = "go to photo my great photo on Fotohäcker"

      assert actual =~ expected
    end

    test "can click on search result in search", %{conn: conn} do
      _photo =
        Fotohaecker.ContentFixtures.photo_fixture(%{
          title: "my great photo"
        })

      {:ok, view, _html} = live(conn, "/fh/en_US/search?search_query=great")

      {:ok, conn_new} =
        view
        |> element("#photo-1 > a")
        |> render_click()
        |> follow_redirect(conn, "/fh/en_US/photos/1")

      assert conn_new.resp_body =~ "my great photo"
    end
  end

  describe "one user result" do
    test "disconnected mount works with one result", %{conn: conn} do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :search!, fn _term ->
        [
          %{id: "auth0|123", nickname: "test", picture: "test.jpg"},
          %{id: "auth0|456", nickname: "sigmund", picture: "test.jpg"}
        ]
      end)

      conn = get(conn, "/fh/en_US/search?search_query=sigmund")
      expected = "profile picture of sigmund"
      actual = html_response(conn, 200)
      assert actual =~ expected
    end

    test "connected mount works with one result", %{conn: conn} do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :search!, 2, fn _term ->
        [
          %{id: "auth0|123", nickname: "test", picture: "test.jpg"},
          %{id: "auth0|456", nickname: "sigmund", picture: "test.jpg"}
        ]
      end)

      {:ok, _view, actual} = live(conn, "/fh/en_US/search?search_query=sigmund")
      expected = "profile picture of sigmund"

      assert actual =~ expected
    end

    test "can click on search result in search", %{conn: conn} do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :search!, 2, fn _term ->
        [
          %{id: "auth0|123", nickname: "test", picture: "test.jpg"},
          %{id: "auth0|456", nickname: "sigmund", picture: "test.jpg"}
        ]
      end)

      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get, 2, fn _user_id ->
        {:ok, %{id: "auth0|456", nickname: "sigmund", picture: "test.jpg"}}
      end)

      {:ok, view, _html} = live(conn, "/fh/en_US/search?search_query=sigmund")

      {:ok, conn_new} =
        view
        |> element("a", "sigmund")
        |> render_click()
        |> follow_redirect(conn, "/fh/en_US/user/auth0%7C456")

      assert conn_new.resp_body =~ "sigmund"
    end
  end
end
