defmodule Fotohaecker.Content.Photo do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :description, :string
    field :file_name, :string
    field :tags, {:array, :string}
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:title, :description, :file_name, :tags])
    |> validate_required([:title, :description, :file_name, :tags])
  end
end
