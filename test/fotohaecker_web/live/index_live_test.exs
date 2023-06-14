defmodule FotohaeckerWeb.IndexLiveTest do
  use FotohaeckerWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  @endpoint FotohaeckerWeb.Endpoint

  test "disconnected mount works", %{conn: conn} do
    conn = get(conn, "/fh")
    expected = "Upload your photos, license-free."
    actual = html_response(conn, 200)
    assert actual =~ expected
  end

  test "connected mount works", %{conn: conn} do
    {:ok, _view, actual} = live(conn, "/fh")
    expected = "Upload your photos, license-free."

    assert actual =~ expected
  end

  test "shows error message if title is too long", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/fh")

    actual =
      view
      |> element(".upload_form")
      |> render_change(%{
        photo: %{
          title: "Way too long title for a photo. Veeeeery Long!11"
        }
      })

    expected =
      "<span class=\"invalid-feedback\" phx-feedback-for=\"photo[title]\">should be at most 32 character(s)</span>"

    assert actual =~ expected
  end
end
