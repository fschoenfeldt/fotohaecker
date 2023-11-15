defmodule FotohaeckerWeb.SearchComponentTest do
  use FotohaeckerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  @endpoint FotohaeckerWeb.Endpoint

  alias FotohaeckerWeb.HeaderLive.NavigationComponent.SearchComponent
  alias Fotohaecker.Search

  describe "search/1" do
    test "renders with search results" do
      search_results = [
        %Search{
          type: :user,
          user: %{
            id: "auth0|123",
            nickname: "testuser"
          }
        },
        %Search{
          type: :photo,
          photo: %{
            id: 1,
            title: "testphoto"
          }
        }
      ]

      search_query = "test"
      myself = __MODULE__

      actual =
        render_component(&SearchComponent.search/1,
          search_results: search_results,
          search_query: search_query,
          myself: myself
        )

      assert actual =~ "testuser"
      assert actual =~ "testphoto"
      assert actual =~ FotohaeckerWeb.LiveHelpers.user_route("auth0|123")
      assert actual =~ FotohaeckerWeb.LiveHelpers.photo_route(1)
    end

    test "renders with no search results" do
      search_results = []
      search_query = "test"
      myself = __MODULE__

      actual =
        render_component(&SearchComponent.search/1,
          search_results: search_results,
          search_query: search_query,
          myself: myself
        )

      assert actual =~ "No results"
    end
  end
end
