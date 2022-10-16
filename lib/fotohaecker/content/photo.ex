defmodule Fotohaecker.Content.Photo do
  @moduledoc false
  use TypedEctoSchema
  import Ecto.Changeset

  typed_schema "photos" do
    field :description, :string
    field :file_name, :string
    field :tags, {:array, :string}
    field :title, :string

    timestamps(type: :naive_datetime_usec)
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:title, :description, :file_name, :tags])
    |> validate_required([:title, :description, :file_name, :tags])
  end
end
