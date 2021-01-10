defmodule Fotohaecker.Content.Photo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "photos" do
    field :description, :string
    field :path, :string
    field :tags, {:array, :string}
    field :title, :string
    field :uploaded, :utc_datetime
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:title, :description, :path, :tags, :uploaded])
    |> foreign_key_constraint(:user_id)
    |> validate_required([:title, :description, :path, :uploaded])
  end
end
