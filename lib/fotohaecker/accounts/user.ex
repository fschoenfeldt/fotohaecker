defmodule Fotohaecker.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Fotohaecker.Content

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :profile_picture, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :password, :email, :profile_picture])
    |> validate_required([:name, :password, :email])
  end
end
