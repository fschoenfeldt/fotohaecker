defmodule Fotohaecker.ContentFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Fotohaecker.Content` context.
  """

  @doc """
  Generate a photo.
  """
  def photo_fixture(attrs \\ %{}) do
    {:ok, photo} =
      attrs
      |> Enum.into(%{
        description: "some description",
        file_name: "some_file_name",
        tags: [],
        title: "some title",
        extension: ".jpg"
      })
      |> Fotohaecker.Content.create_photo()

    photo
  end

  @doc """
  Create a changeset for a photo.
  """
  def photo_changeset(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        file_name: "some_file_name",
        tags: [],
        title: "some title",
        extension: ".jpg"
      })

    Fotohaecker.Content.change_photo(%Fotohaecker.Content.Photo{}, attrs)
  end

  @doc """
  Generate a recipe.
  """
  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{
        title: "any title",
        brand: "any brand",
        user_id: "some_user_id",
        settings: %{
          "compatible" => "xtrans-iv",
          "base_simulation" => "Classic Negative",
          "highlight" => -1,
          "shadow" => 1
        },
        description: """
        ## Some subtitle for this recipe
        sic semper tyrannis
        """
      })
      |> Fotohaecker.Content.create_recipe()

    recipe
  end
end
