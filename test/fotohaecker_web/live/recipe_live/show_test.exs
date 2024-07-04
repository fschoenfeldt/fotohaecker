defmodule FotohaeckerWeb.RecipeLive.ShowTest do
  use FotohaeckerWeb.ConnCase, async: true

  import Phoenix.ConnTest
  import Phoenix.LiveViewTest

  alias FotohaeckerWeb.RecipeLive.Show.RecipeNotFoundError

  @endpoint FotohaeckerWeb.Endpoint

  # FIXME: add tests

  test "throws error if recipe not found", %{conn: conn} do
    assert_raise(RecipeNotFoundError, fn ->
      {:ok, _view, _html} = live(conn, "/fh/en_US/recipes/12345")
    end)
  end
end
