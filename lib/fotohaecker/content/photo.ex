defmodule Fotohaecker.Content.Photo do
  @moduledoc false
  use TypedEctoSchema
  import Ecto.Changeset

  typed_schema "photos" do
    field :title, :string
    field :file_name, :string
    field :tags, {:array, :string}

    timestamps(type: :naive_datetime_usec)
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:title, :file_name, :tags])
    |> validate_length(:title, min: 1, max: 2)
    |> validate_required([:title, :file_name])
  end
end
