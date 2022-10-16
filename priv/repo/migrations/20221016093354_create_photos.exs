defmodule Fotohaecker.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :title, :string
      add :description, :string
      add :file_name, :string
      add :tags, {:array, :string}

      timestamps()
    end
  end
end
