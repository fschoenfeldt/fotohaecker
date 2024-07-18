defmodule Fotohaecker.RecipeManagement.NoRecipeManagement do
  @moduledoc """
  Fallback module when no recipe management is enabled via config.
  """

  @behaviour Fotohaecker.RecipeManagement.RecipeManagementBehaviour
  alias Fotohaecker.RecipeManagement.RecipeManagementBehaviour

  @impl RecipeManagementBehaviour
  def get_all do
    {:error, :not_implemented}
  end

  @impl RecipeManagementBehaviour
  def get(_recipe_id) do
    {:error, :not_implemented}
  end

  @impl RecipeManagementBehaviour
  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end
end
