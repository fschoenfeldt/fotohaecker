defmodule Fotohaecker.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos) do
      add :title, :string
      add :description, :string
      add :path, :string
      add :tags, {:array, :string}
      add :uploaded, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:photos, [:user_id])
  end
end
