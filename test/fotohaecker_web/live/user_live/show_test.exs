defmodule FotohaeckerWeb.UserLive.ShowTest do
  use FotohaeckerWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import Mox
  @endpoint FotohaeckerWeb.Endpoint

  describe "shows user nickname" do
    setup do
      expect(Fotohaecker.UserManagement.UserManagementMock, :get, 2, fn "1337" ->
        {
          :ok,
          %{
            email: "test@test.de",
            nickname: "any_nickname",
            picture: "https://picsum.photos/300/300"
          }
        }
      end)

      :ok
    end

    test "disconnected mount works", %{conn: conn} do
      conn = get(conn, "/fh/en_US/user/1337")
      expected = "any_nickname"
      actual = html_response(conn, 200)
      assert actual =~ expected
    end

    test "connected mount works", %{conn: conn} do
      {:ok, _view, actual} = live(conn, "/fh/en_US/user/1337")
      expected = "any_nickname"

      assert actual =~ expected
    end
  end

  test "shows error message if user is not found", %{conn: conn} do
    # get gets called twice because of `OnMount.CurrentUser`
    expect(Fotohaecker.UserManagement.UserManagementMock, :get, 2, fn _user_id ->
      {
        :error,
        %{
          "error" => "Not Found",
          "errorCode" => "inexistent_user",
          "message" => "The user does not exist.",
          "statusCode" => 404
        }
      }
    end)

    {:ok, _view, actual} = live(conn, "/fh/en_US/user/1338")
    expected = "404: The user does not exist."

    assert actual =~ expected
  end
end
