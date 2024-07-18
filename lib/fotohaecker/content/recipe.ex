defmodule Fotohaecker.Content.Recipe do
  @moduledoc """
  a recipe is a collection of settings that can be applied to a photo.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer(),
          title: String.t(),
          description: String.t(),
          brand: String.t(),
          user_id: String.t(),
          settings: map(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }
  schema "recipe" do
    field :title, :string
    field :description, :string
    field :brand, :string
    field :user_id, :string
    field :settings, :map
    has_many(:photos, Fotohaecker.Content.Photo, foreign_key: :recipe_id)

    timestamps(type: :naive_datetime_usec)
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:title, :description, :brand, :user_id, :settings])
    |> validate_required([:title, :brand, :user_id, :settings])
  end
end
