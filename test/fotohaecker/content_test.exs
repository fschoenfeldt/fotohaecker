defmodule Fotohaecker.ContentTest do
  use Fotohaecker.DataCase, async: false

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo
  import Fotohaecker.ContentFixtures

  describe "photos" do
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

    test "list_photos/2" do
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

    test "list_photos_by_user/2" do
      user_id = "auth0|123456789"
      photo_1 = photo_fixture(%{user_id: user_id})
      photo_2 = photo_fixture(%{user_id: user_id})
      photo_3 = photo_fixture(%{user_id: user_id})
      photo_4 = photo_fixture(%{user_id: user_id})
      photo_5 = photo_fixture(%{user_id: user_id})

      actual = Content.list_photos_by_user(user_id, 3, 1)

      expected = [
        photo_4,
        photo_3,
        photo_2
      ]

      assert actual == expected
    end

    test "list_photos_by_user/2 empty result" do
      user_id = "auth0|123456789"
      another_user_id = "auth0|987654321"
      photo_1 = photo_fixture(%{user_id: user_id})

      actual = Content.list_photos_by_user(another_user_id, 3, 10)

      expected = []

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

    test "create_photo/1 with valid data and user_id creates a photo" do
      user_id = "auth0|123456789"

      valid_attrs = %{
        file_name: "some file_name",
        tags: [],
        title: "some title",
        extension: ".jpg",
        user_id: user_id
      }

      assert {:ok, %Photo{} = photo} = Content.create_photo(valid_attrs)
      assert photo.file_name == "some file_name"
      assert photo.tags == []
      assert photo.title == "some title"
      assert photo.user_id == user_id
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
      photo_paths = Content.photo_paths(photo)
      # write empty binary files to the destination paths
      Enum.each(photo_paths, fn path ->
        File.write!(path, "")
      end)

      assert {:ok, %Photo{}} = Content.delete_photo(photo)

      assert photo_paths
             |> Enum.map(fn path -> File.exists?(path) end)
             |> Enum.all?(fn exists -> exists == false end)

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

  describe "search_photos/1" do
    test "works with title" do
      data = [
        %{title: "Test1", tags: ["tag1", "tag2"]},
        %{title: "Test2", tags: ["tag1", "tag2"]}
      ]

      [photo_1, _photo_2] = Enum.map(data, fn attrs -> photo_fixture(attrs) end)

      actual = Content.search_photos("Test1")

      expected = [
        photo_1
      ]

      assert actual == expected
    end

    test "works with tags" do
      data = [
        %{title: "Test1", tags: ["tag1", "tag2"]},
        %{title: "Test2", tags: ["tag1", "tag2"]}
      ]

      [photo_1, photo_2] = Enum.map(data, fn attrs -> photo_fixture(attrs) end)

      actual = Content.search_photos("tag1")

      expected = [
        photo_1,
        photo_2
      ]

      assert actual == expected
    end

    test "works with tags and title combined" do
      data = [
        %{title: "Test1", tags: ["tag1", "tag2"]},
        %{title: "tag1", tags: ["tag1", "tag2"]}
      ]

      expected = Enum.map(data, fn attrs -> photo_fixture(attrs) end)

      actual = Content.search_photos("tag1")

      assert actual == expected
    end

    test "works with no results" do
      data = [
        %{title: "Test1", tags: ["tag1", "tag2"]},
        %{title: "tag1", tags: ["tag1", "tag2"]}
      ]

      Enum.map(data, fn attrs -> photo_fixture(attrs) end)

      actual = Content.search_photos("tag3")

      expected = []

      assert actual == expected
    end
  end
end
