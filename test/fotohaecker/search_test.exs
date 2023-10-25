defmodule Fotohaecker.SearchTest do
  alias Fotohaecker.ContentFixtures
  use Fotohaecker.DataCase, async: true
  import Mox
  alias Fotohaecker.Search

  setup :verify_on_exit!

  describe "search/1" do
    test "finds user by name" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        [%{id: "auth0|123", nickname: "test"}, %{id: "auth0|456", nickname: "sigmund"}]
      end)

      actual = Search.search("test")
      expected = [%{type: :user, user: %{nickname: "test", id: "auth0|123"}}]

      assert actual == expected
    end

    test "finds multiple users by name" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        [
          %{id: "auth0|123", nickname: "test"},
          %{id: "auth0|456", nickname: "test2"},
          %{
            id: "auth0|789",
            nickname: "sigmund"
          }
        ]
      end)

      actual = Search.search("test")

      expected = [
        %{type: :user, user: %{nickname: "test", id: "auth0|123"}},
        %{type: :user, user: %{nickname: "test2", id: "auth0|456"}}
      ]

      assert actual == expected
    end

    test "returns empty list when no results found" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        [%{id: "auth0|123", nickname: "test"}, %{id: "auth0|456", nickname: "sigmund"}]
      end)

      actual = Search.search("freud")
      expected = []

      assert actual == expected
    end

    test "finds photo" do
      Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
        [
          %{
            id: "auth0|789",
            nickname: "sigmund"
          }
        ]
      end)

      ContentFixtures.photo_fixture(%{
        title: "test"
      })

      actual = Search.search("test")
      assert length(actual) == 1

      assert hd(actual).type == :photo
      assert hd(actual).photo.title == "test"
    end
  end
end
