defmodule Fotohaecker.RecipeManagement.JsonRecipeManagement.JsonRecipeImporter do
  @moduledoc """
  This module provides functionality for importing recipes from JSON files and is part of the JSON recipe management system -> `Fotohaecker.RecipeManagement.JsonRecipeManagement`.
  """
  alias Fotohaecker.Content.Recipe
  alias Fotohaecker.Repo

  require Logger

  # def import_succeeded_or_log(import_results) do
  #   import_results
  #   |> Enum.all?(fn
  #     {:ok, _} -> true
  #     _error -> false
  #   end)
  #   |> succeded_or_log(import_results)
  # end

  # defp succeded_or_log(true, _results), do: true

  # defp succeded_or_log(false, error),
  #   do: Logger.warning("Error importing some recipes: #{inspect(error)}")

  @spec import_recipes_from_directory(binary()) ::
          list(
            {:ok,
             {
               :ok,
               %{
                 recipe: Fotohaecker.Content.Recipe.t(),
                 file_path: binary()
               }
             }}
            | {:error, map()}
          )
  def import_recipes_from_directory(directory) do
    directory
    |> File.ls!()
    |> Enum.map(&import_recipe_from_file(Path.join(directory, &1)))
  end

  defp import_recipe_from_file(file_path) do
    case file_path
         |> File.read!()
         |> Jason.decode() do
      {:ok, data} ->
        insert_recipe_if_new(data, file_path)

      jason_error ->
        {:error,
         %{
           error: jason_error,
           file_path: file_path
         }}
    end
  end

  defp insert_recipe_if_new(
         %{"title" => title, "user_id" => user_id, "settings" => _settings} = params,
         file_path
       ) do
    case Repo.get_by(Recipe, title: title, user_id: user_id) do
      nil ->
        {:ok, %{recipe: Fotohaecker.Content.create_recipe(params), file_path: file_path}}

      recipe ->
        {:ok, %{recipe: recipe, file_path: file_path}}
    end
  end
end
