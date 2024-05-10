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
end
