defmodule Fotohaecker.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :password, :string
      add :email, :string
      add :profile_picture, :string

      timestamps()
    end

  end
end
