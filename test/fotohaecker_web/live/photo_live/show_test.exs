defmodule FotohaeckerWeb.PhotoLive.ShowTest do
  use FotohaeckerWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias FotohaeckerWeb.PhotoLive.Show.PhotoNotFoundError
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

  test "opens modal when clicking delete button", %{conn: conn} do
    photo =
      Fotohaecker.ContentFixtures.photo_fixture(%{
        title: "adastraperaspera"
      })

    {:ok, view, _html} = live(conn, "/fh/en_US/photos/#{photo.id}")

    actual =
      view
      |> element("button", "Delete")
      |> render_click()

    expected = "Are you sure you want to delete this photo?"
    assert actual =~ expected
  end

  test "deletes photo on `delete_photo` event", %{conn: conn} do
    photo =
      Fotohaecker.ContentFixtures.photo_fixture(%{
        title: "adastraperaspera"
      })

    {:ok, view, _html} = live(conn, "/fh/en_US/photos/#{photo.id}")

    {:ok, _view, actual} =
      view
      |> render_click("delete_photo")
      |> follow_redirect(conn, "/fh/en_US")

    expected = "photo deleted"
    assert actual =~ expected
  end

  test "throws error if photo not found", %{conn: conn} do
    assert_raise(PhotoNotFoundError, fn ->
      {:ok, _view, _html} = live(conn, "/fh/en_US/photos/12345")
    end)
  end
end
