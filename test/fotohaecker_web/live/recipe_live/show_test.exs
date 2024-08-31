defmodule FotohaeckerWeb.RecipeLive.ShowTest do
  use FotohaeckerWeb.ConnCase, async: false

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias FotohaeckerWeb.RecipeLive.Show.RecipeNotFoundError

  @endpoint FotohaeckerWeb.Endpoint

  setup do
    Mox.stub(
      Fotohaecker.UserManagement.UserManagementMock,
      :get,
      fn "some_user_id" ->
        {:ok,
         %{
           id: "some_user_id",
           nickname: "test"
         }}
      end
    )

    on_exit(fn ->
      Application.put_env(
        :fotohaecker,
        Fotohaecker.UserManagement,
        Fotohaecker.UserManagement.UserManagementMock
      )
    end)

    :ok
  end

  test "disconnected mount works", %{conn: conn} do
    recipe =
      Fotohaecker.ContentFixtures.recipe_fixture(%{
        title: "adastraperaspera"
      })

    conn = get(conn, "/fh/en_US/recipes/#{recipe.id}")

    expected = [
      "adastraperaspera",
      "Settings",
      "Some subtitle for this recipe",
      "sic semper tyrannis"
    ]

    actual = html_response(conn, 200)
    assert Enum.all?(expected, &(actual =~ &1))
  end

  test "connected mount works", %{conn: conn} do
    recipe =
      Fotohaecker.ContentFixtures.recipe_fixture(%{
        title: "adastraperaspera"
      })

    {:ok, _view, actual} = live(conn, "/fh/en_US/recipes/#{recipe.id}")

    expected = [
      "adastraperaspera",
      "Settings",
      "Some subtitle for this recipe",
      "sic semper tyrannis"
    ]

    assert Enum.all?(expected, &(actual =~ &1))
  end

  test "renders assocoiated photos and redirects upon clicking them", %{conn: conn} do
    recipe =
      Fotohaecker.ContentFixtures.recipe_fixture(%{
        title: "adastraperaspera"
      })

    _photo =
      Fotohaecker.ContentFixtures.photo_fixture(%{
        title: "photo title",
        recipe_id: recipe.id
      })

    {:ok, view, actual} = live(conn, "/fh/en_US/recipes/#{recipe.id}")

    expected = ["Photos using this recipe", "photo title"]
    assert Enum.all?(expected, &(actual =~ &1))

    view
    |> element("a", "photo title")
    |> render_click()
    |> follow_redirect(conn, "/fh/en_US/photos/1")
  end

  test "throws error if recipe not found", %{conn: conn} do
    assert_raise(RecipeNotFoundError, fn ->
      {:ok, _view, _html} = live(conn, "/fh/en_US/recipes/12345")
    end)
  end
end
