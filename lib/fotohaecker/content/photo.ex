defmodule Fotohaecker.Content.Photo do
  @moduledoc false
  use TypedEctoSchema
  import Ecto.Changeset

  typed_schema "photos" do
    field :title, :string
    field :file_name, :string
    field :extension, :string
    field :tags, {:array, :string}

    timestamps(type: :naive_datetime_usec)
  end

  def gen_path(filename) do
    Path.join([
      :code.priv_dir(:fotohaecker),
      "static",
      "images",
      "uploads",
      filename
    ])
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:title, :file_name, :tags, :extension])
    |> validate_length(:title, min: 1, max: 8)
    |> validate_required([:title, :file_name, :extension])
  end
end
