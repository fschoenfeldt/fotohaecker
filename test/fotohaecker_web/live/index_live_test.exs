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
          title: "Way too long title for a photo"
        }
      })

    expected =
      "<span class=\"invalid-feedback\" phx-feedback-for=\"photo[title]\">should be at most 16 character(s)</span>"

    assert actual =~ expected
  end

  # test "upload works", %{conn: conn} do
  #   {:ok, view, _html} = live(conn, "/fh")

  #   photo_file =
  #     file_input(view, ".upload_form", :photo, [
  #       %{
  #         last_modified: 1_594_171_879_000,
  #         name: "my-first-photo_og.jpg",
  #         content: File.read!("priv/static/uploads/my-first-photo_og.jpg"),
  #         size: 1_396_009,
  #         type: "image/jpeg"
  #       }
  #     ])

  #   render_upload(photo_file, "my-first-photo_og.jpg")
  #   |> IO.inspect()

  #   # actual =
  #   #   view
  #   #   |> element(".upload_form")
  #   #   |> render_submit(%{
  #   #     photo: %{
  #   #       title: "My photo",
  #   #       tags: "tag 1, tag 2"
  #   #     }
  #   #   })
  #   #   |> IO.inspect()

  #   #    assert actual =~ expected
  # end

  # TODO: test upload
end
