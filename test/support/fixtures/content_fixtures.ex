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
        file_name: "some file_name",
        tags: [],
        title: "some title",
        extension: ".jpg"
      })
      |> Fotohaecker.Content.create_photo()

    photo
  end
end
