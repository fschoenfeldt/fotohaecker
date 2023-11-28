defmodule FotohaeckerWeb.IndexLiveTest do
  alias Fotohaecker.ContentFixtures
  use FotohaeckerWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest
  import ContentFixtures
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

defmodule FotohaeckerWeb.IndexLiveSyncTest do
  alias Fotohaecker.ContentFixtures
  use FotohaeckerWeb.ConnCase, async: false

  import Phoenix.LiveViewTest
  import ContentFixtures
  @endpoint FotohaeckerWeb.Endpoint

  test "can click on 'more photos' button", %{conn: conn} do
    Enum.each(
      1..6,
      fn _i -> photo_fixture() end
    )

    {:ok, view, _html} = live(conn, "/fh")

    assert render(view) =~ "showing 5 out of 6 photos"

    actual =
      view
      |> element("[data-testid=\"show_more_photos_button\"]")
      |> render_click()

    assert actual =~ "showing 6 out of 6 photos"

    assert Enum.all?(1..6, fn photo_id ->
             actual =~ "photo-#{photo_id}"
           end)
  end

  test "can click on 'sort by' options", %{conn: conn} do
    Enum.each(
      1..6,
      fn _i -> photo_fixture() end
    )

    {:ok, view, _html} = live(conn, "/fh")

    actual_before = render(view)

    assert actual_before =~ "showing 5 out of 6 photos"

    assert Enum.all?(6..2, fn photo_id ->
             actual_before =~ "photo-#{photo_id}"
           end)

    refute actual_before =~ "photo-1"

    actual =
      view
      |> element("a", "oldest")
      |> render_click()

    assert actual =~ "showing 5 out of 6 photos"

    assert actual =~
             "<a phx-click=\"sort_by\" phx-value-order=\"asc_inserted_at\" href=\"#\" class=\"sortby-options__option sortby-options__option--active\">\n          oldest\n        </a>"

    assert Enum.all?(1..5, fn photo_id ->
             actual =~ "photo-#{photo_id}"
           end)

    refute actual =~ "photo-6"
  end
end
