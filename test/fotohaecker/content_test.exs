defmodule Fotohaecker.ContentTest do
  use Fotohaecker.DataCase

  alias Fotohaecker.Content

  describe "photos" do
    alias Fotohaecker.Content.Photo

    @valid_attrs %{description: "some description", path: "some path", tags: [], title: "some title", uploaded: "2010-04-17T14:00:00Z"}
    @update_attrs %{description: "some updated description", path: "some updated path", tags: [], title: "some updated title", uploaded: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{description: nil, path: nil, tags: nil, title: nil, uploaded: nil}

    def photo_fixture(attrs \\ %{}) do
      {:ok, photo} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Content.create_photo()

      photo
    end

    test "list_photos/0 returns all photos" do
      photo = photo_fixture()
      assert Content.list_photos() == [photo]
    end

    test "get_photo!/1 returns the photo with given id" do
      photo = photo_fixture()
      assert Content.get_photo!(photo.id) == photo
    end

    test "create_photo/1 with valid data creates a photo" do
      assert {:ok, %Photo{} = photo} = Content.create_photo(@valid_attrs)
      assert photo.description == "some description"
      assert photo.path == "some path"
      assert photo.tags == []
      assert photo.title == "some title"
      assert photo.uploaded == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_photo(@invalid_attrs)
    end

    test "update_photo/2 with valid data updates the photo" do
      photo = photo_fixture()
      assert {:ok, %Photo{} = photo} = Content.update_photo(photo, @update_attrs)
      assert photo.description == "some updated description"
      assert photo.path == "some updated path"
      assert photo.tags == []
      assert photo.title == "some updated title"
      assert photo.uploaded == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_photo/2 with invalid data returns error changeset" do
      photo = photo_fixture()
      assert {:error, %Ecto.Changeset{}} = Content.update_photo(photo, @invalid_attrs)
      assert photo == Content.get_photo!(photo.id)
    end

    test "delete_photo/1 deletes the photo" do
      photo = photo_fixture()
      assert {:ok, %Photo{}} = Content.delete_photo(photo)
      assert_raise Ecto.NoResultsError, fn -> Content.get_photo!(photo.id) end
    end

    test "change_photo/1 returns a photo changeset" do
      photo = photo_fixture()
      assert %Ecto.Changeset{} = Content.change_photo(photo)
    end
  end
end
