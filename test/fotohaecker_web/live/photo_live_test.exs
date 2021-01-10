defmodule FotohaeckerWeb.PhotoLiveTest do
  use FotohaeckerWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Fotohaecker.Content

  @create_attrs %{description: "some description", path: "some path", tags: [], title: "some title", uploaded: "2010-04-17T14:00:00Z"}
  @update_attrs %{description: "some updated description", path: "some updated path", tags: [], title: "some updated title", uploaded: "2011-05-18T15:01:01Z"}
  @invalid_attrs %{description: nil, path: nil, tags: nil, title: nil, uploaded: nil}

  defp fixture(:photo) do
    {:ok, photo} = Content.create_photo(@create_attrs)
    photo
  end

  defp create_photo(_) do
    photo = fixture(:photo)
    %{photo: photo}
  end

  describe "Index" do
    setup [:create_photo]

    test "lists all photos", %{conn: conn, photo: photo} do
      {:ok, _index_live, html} = live(conn, Routes.photo_index_path(conn, :index))

      assert html =~ "Listing Photos"
      assert html =~ photo.description
    end

    test "saves new photo", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.photo_index_path(conn, :index))

      assert index_live |> element("a", "New Photo") |> render_click() =~
               "New Photo"

      assert_patch(index_live, Routes.photo_index_path(conn, :new))

      assert index_live
             |> form("#photo-form", photo: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#photo-form", photo: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.photo_index_path(conn, :index))

      assert html =~ "Photo created successfully"
      assert html =~ "some description"
    end

    test "updates photo in listing", %{conn: conn, photo: photo} do
      {:ok, index_live, _html} = live(conn, Routes.photo_index_path(conn, :index))

      assert index_live |> element("#photo-#{photo.id} a", "Edit") |> render_click() =~
               "Edit Photo"

      assert_patch(index_live, Routes.photo_index_path(conn, :edit, photo))

      assert index_live
             |> form("#photo-form", photo: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#photo-form", photo: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.photo_index_path(conn, :index))

      assert html =~ "Photo updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes photo in listing", %{conn: conn, photo: photo} do
      {:ok, index_live, _html} = live(conn, Routes.photo_index_path(conn, :index))

      assert index_live |> element("#photo-#{photo.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#photo-#{photo.id}")
    end
  end

  describe "Show" do
    setup [:create_photo]

    test "displays photo", %{conn: conn, photo: photo} do
      {:ok, _show_live, html} = live(conn, Routes.photo_show_path(conn, :show, photo))

      assert html =~ "Show Photo"
      assert html =~ photo.description
    end

    test "updates photo within modal", %{conn: conn, photo: photo} do
      {:ok, show_live, _html} = live(conn, Routes.photo_show_path(conn, :show, photo))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Photo"

      assert_patch(show_live, Routes.photo_show_path(conn, :edit, photo))

      assert show_live
             |> form("#photo-form", photo: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#photo-form", photo: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.photo_show_path(conn, :show, photo))

      assert html =~ "Photo updated successfully"
      assert html =~ "some updated description"
    end
  end
end
