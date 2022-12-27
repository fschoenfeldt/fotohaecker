defmodule Fotohaecker.ContentTest do
  use Fotohaecker.DataCase

  alias Fotohaecker.Content

  describe "photos" do
    alias Fotohaecker.Content.Photo

    import Fotohaecker.ContentFixtures

    @invalid_attrs %{file_name: nil, tags: nil, title: nil}

    test "list_photos/0 returns all photos" do
      photo = photo_fixture()
      assert Content.list_photos() == [photo]
    end

    test "list_photos/0" do
      Enum.map(1..20, fn _i -> photo_fixture() end)
      actual = length(Content.list_photos())
      expected = 10

      assert actual == expected
    end

    test "list_photos/1" do
      Enum.map(1..20, fn _i -> photo_fixture() end)
      actual = length(Content.list_photos(5))
      expected = 5

      assert actual == expected
    end

    test "list_photos/2 " do
      _photo_1 = photo_fixture(%{title: "test1"})
      photo_2 = photo_fixture(%{title: "test2"})
      photo_3 = photo_fixture(%{title: "test3"})
      photo_4 = photo_fixture(%{title: "test4"})
      _photo_5 = photo_fixture(%{title: "test5"})

      actual = Content.list_photos(3, 1)

      expected = [
        photo_4,
        photo_3,
        photo_2
      ]

      assert actual == expected
    end

    test "get_photo!/1 returns the photo with given id" do
      photo = photo_fixture()
      assert Content.get_photo!(photo.id) == photo
    end

    test "create_photo/1 with valid data creates a photo" do
      valid_attrs = %{
        file_name: "some file_name",
        tags: [],
        title: "some title",
        extension: ".jpg"
      }

      assert {:ok, %Photo{} = photo} = Content.create_photo(valid_attrs)
      assert photo.file_name == "some file_name"
      assert photo.tags == []
      assert photo.title == "some title"
    end

    test "create_photo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Content.create_photo(@invalid_attrs)
    end

    test "update_photo/2 with valid data updates the photo" do
      photo = photo_fixture()

      update_attrs = %{
        file_name: "some updated file_name",
        tags: [],
        title: "updated",
        extension: ".jpg"
      }

      assert {:ok, %Photo{} = photo} = Content.update_photo(photo, update_attrs)
      assert photo.file_name == "some updated file_name"
      assert photo.tags == []
      assert photo.title == "updated"
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

    test "photos_count/0" do
      Enum.map(1..20, fn _i -> photo_fixture() end)
      actual = Content.photos_count()
      expected = 20

      assert actual == expected
    end
  end
end
