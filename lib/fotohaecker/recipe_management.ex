defmodule Fotohaecker.RecipeManagement do
  @moduledoc """
  This module provides recipe management functionality.

  It implements the `Fotohaecker.RecipeManagement.RecipeManagementBehaviour` behaviour, which defines the interface for recipe management.
  """

  @behaviour Fotohaecker.RecipeManagement.RecipeManagementBehaviour
  alias Fotohaecker.RecipeManagement.NoRecipeManagement
  alias Fotohaecker.RecipeManagement.RecipeManagementBehaviour

  @impl RecipeManagementBehaviour
  @doc """
  Get all recipes
  """
  def get_all, do: implementation().get_all()

  @impl RecipeManagementBehaviour
  @doc """
  Get a recipe by its ID
  """
  def get(recipe_id), do: implementation().get(recipe_id)

  @impl RecipeManagementBehaviour
  @doc """
  Starts the recipe management process
  """
  def start_link(initial_value \\ []) do
    implementation().start_link(initial_value)
  end

  @impl RecipeManagementBehaviour
  @doc """
  Returns true if the recipe management is implemented.
  """
  def is_implemented?(), do: implementation() != NoRecipeManagement

  defp implementation,
    do:
      Application.get_env(
        :fotohaecker,
        __MODULE__,
        NoRecipeManagement
      )
end
