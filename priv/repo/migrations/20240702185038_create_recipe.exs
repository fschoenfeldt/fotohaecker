defmodule Fotohaecker.Repo.Migrations.CreateRecipe do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      add(:recipe_id, references(:recipe, on_delete: :nothing))
    end

    create table(:recipe) do
      add :title, :string
      add :description, :string
      add :brand, :string
      add :user_id, :string
      add :settings, :map

      timestamps()
    end
  end
end
