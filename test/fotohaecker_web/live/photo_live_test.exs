defmodule FotohaeckerWeb.PhotoLiveTest do
  use FotohaeckerWeb.ConnCase, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint FotohaeckerWeb.Endpoint

  test "disconnected mount works", %{conn: conn} do
    photo =
      Fotohaecker.ContentFixtures.photo_fixture(%{
        title: "adastraperaspera"
      })

    conn = get(conn, "/fh/en_US/photos/#{photo.id}")
    expected = ["adastraperaspera", "Download"]
    actual = html_response(conn, 200)
    assert Enum.all?(expected, &(actual =~ &1))
  end

  test "connected mount works", %{conn: conn} do
    photo =
      Fotohaecker.ContentFixtures.photo_fixture(%{
        title: "adastraperaspera"
      })

    {:ok, _view, actual} = live(conn, "/fh/en_US/photos/#{photo.id}")

    expected = ["adastraperaspera", "Download"]
    assert Enum.all?(expected, &(actual =~ &1))
  end

  test "throws error if photo not found", %{conn: conn} do
    assert_raise(FotohaeckerWeb.PhotoLive.Show.PhotoNotFoundError, fn ->
      {:ok, _view, _html} = live(conn, "/fh/en_US/photos/12345")
    end)
  end
end
