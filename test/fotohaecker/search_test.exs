defmodule Fotohaecker.SearchTest do
  alias Fotohaecker.ContentFixtures
  use Fotohaecker.DataCase, async: false
  import Mox
  alias Fotohaecker.Search
  doctest Fotohaecker.Search

  setup :verify_on_exit!

  setup do
    Mox.stub(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
      {:ok, []}
    end)

    on_exit(fn ->
      Application.put_env(
        :fotohaecker,
        Fotohaecker.UserManagement,
        Fotohaecker.UserManagement.UserManagementMock
      )
    end)

    :ok
  end

  describe "search/1" do
    test "finds user by name" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        {:ok,
         [
           %{id: "auth0|123", nickname: "test"},
           %{id: "auth0|456", nickname: "sigmund"}
         ]}
      end)

      actual = Search.search("test")
      expected = [%Search{type: :user, user: %{nickname: "test", id: "auth0|123"}, photo: nil}]

      assert actual == expected
    end

    test "finds multiple users by name" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        {:ok,
         [
           %{id: "auth0|123", nickname: "test"},
           %{id: "auth0|456", nickname: "test2"},
           %{
             id: "auth0|789",
             nickname: "sigmund"
           }
         ]}
      end)

      actual = Search.search("test")

      expected = [
        %Search{type: :user, user: %{nickname: "test", id: "auth0|123"}},
        %Search{type: :user, user: %{nickname: "test2", id: "auth0|456"}}
      ]

      assert actual == expected
    end

    test "returns empty list when empty string provided as input" do
      actual = Search.search("")

      expected = []
      assert actual == expected
    end

    test "returns empty list when only white space provided as input" do
      ContentFixtures.photo_fixture(%{
        title: "test with double  whitespace"
      })

      actual = Search.search("  ")

      expected = []
      assert actual == expected
    end

    test "returns empty list when no results found" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        {:ok, [%{id: "auth0|123", nickname: "test"}, %{id: "auth0|456", nickname: "sigmund"}]}
      end)

      actual = Search.search("freud")
      expected = []

      assert actual == expected
    end

    test "returns empty list when UserManagment returns error" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        {:error, "error"}
      end)

      actual = Search.search("test")
      expected = []

      assert actual == expected
    end

    test "finds photo" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        {:ok,
         [
           %{
             id: "auth0|789",
             nickname: "sigmund"
           }
         ]}
      end)

      ContentFixtures.photo_fixture(%{
        title: "test"
      })

      actual = Search.search("test")
      assert length(actual) == 1

      assert hd(actual).type == :photo
      assert hd(actual).photo.title == "test"
    end

    test "returns no users when UserManagement is disabled" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, 0, fn ->
        {:ok, []}
      end)

      Application.put_env(
        :fotohaecker,
        Fotohaecker.UserManagement,
        Fotohaecker.UserManagement.NoUserManagement
      )

      actual = Fotohaecker.Search.search("test")
      expected = []

      assert actual == expected
    end
  end
end
