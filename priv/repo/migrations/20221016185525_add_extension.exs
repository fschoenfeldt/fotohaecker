defmodule Fotohaecker.Repo.Migrations.AddExtension do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      add :extension, :string
    end
  end
end
