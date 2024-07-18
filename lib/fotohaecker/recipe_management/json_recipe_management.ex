defmodule Fotohaecker.RecipeManagement.JsonRecipeManagement do
  @moduledoc """
  This module provides recipe management functionality, importing them from JSON files.
  """

  @behaviour Fotohaecker.RecipeManagement.RecipeManagementBehaviour
  alias Fotohaecker.RecipeManagement.RecipeManagementBehaviour
  alias __MODULE__.JsonRecipeImporter

  require Logger

  @impl RecipeManagementBehaviour
  @doc """
  Returns all recipes.
  """
  def get_all do
    Fotohaecker.Content.list_recipe()
  end

  @impl RecipeManagementBehaviour
  def get(id) do
    Fotohaecker.Content.get_recipe(id)
  end

  @impl RecipeManagementBehaviour
  @doc """
  Starts the recipe management process
  """
  def start_link(initial_value \\ []) do
    warm? = Application.get_env(:fotohaecker, __MODULE__)[:warm]

    if warm? == false do
      Agent.start_link(fn -> initial_value end, name: __MODULE__)
    else
      recipe_path = get_recipe_path()
      imported_recipes = JsonRecipeImporter.import_recipes_from_directory(recipe_path)

      # unpack the recipes from the import results
      initial_recipes =
        imported_recipes
        |> Enum.map(&unpack_recipe/1)
        |> Enum.filter(&(&1 != nil))

      # TODO: do we really need the Agents result when were delegating to the database?
      Agent.start_link(fn -> initial_recipes end, name: __MODULE__)
    end
  end

  defp unpack_recipe({:ok, %{recipe: recipe, file_path: _file_path}}), do: recipe

  defp unpack_recipe({:error, error}) do
    Logger.warning("Error importing recipe: #{inspect(error)}")
    nil
  end

  defp get_recipe_path do
    recipe_path =
      :fotohaecker
      |> Application.get_env(Fotohaecker.RecipeManagement.JsonRecipeManagement)
      |> Keyword.get(:recipe_path)

    case Path.type(recipe_path) do
      :absolute ->
        recipe_path

      :relative ->
        Path.join([:code.priv_dir(:fotohaecker), recipe_path])
    end
  end
end
