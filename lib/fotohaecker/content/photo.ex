defmodule Fotohaecker.Content.Photo do
  @moduledoc """
  Photo
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          __meta__: Ecto.Schema.Metadata.t(),
          id: integer(),
          title: String.t(),
          file_name: String.t(),
          extension: String.t(),
          tags: [String.t()],
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t(),
          user_id: String.t()
        }

  schema "photos" do
    field(:title, :string)
    field(:file_name, :string)
    field(:extension, :string)
    field(:tags, {:array, :string})
    field(:user_id, :string)

    timestamps(type: :naive_datetime_usec)
  end

  @doc """
  Generates path for saving a photo
  """
  def gen_path(filename) do
    Path.join([
      :code.priv_dir(:fotohaecker),
      "static",
      "uploads",
      filename
    ])
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:title, :file_name, :tags, :extension, :user_id])
    |> validate_length(:title, min: 1, max: 32)
    |> validate_required([:title, :file_name, :tags, :extension])
  end
end
