defmodule Fotohaecker.RecipeManagementTest do
  use ExUnit.Case, async: false

  alias Fotohaecker.RecipeManagement
  alias Fotohaecker.RecipeManagement.RecipeManagementMock

  import Mox

  setup :verify_on_exit!

  describe "get/1" do
    test "gets recipe" do
      expect(RecipeManagementMock, :get, fn "recipe_id" -> nil end)
      RecipeManagement.get("recipe_id")
    end

    test "error when recipe not found" do
      expect(RecipeManagementMock, :get, fn "recipe_id" ->
        {:error, "error"}
      end)

      RecipeManagement.get("recipe_id")
    end
  end

  describe "get_all/0" do
    test "gets all recipes" do
      expect(RecipeManagementMock, :get_all, fn -> [] end)

      RecipeManagement.get_all()
    end
  end

  describe "start_link/0" do
    test "starts recipe management process" do
      expect(RecipeManagementMock, :start_link, fn [] ->
        {:ok, :started}
      end)

      RecipeManagement.start_link()
    end
  end
end
