defmodule Fotohaecker.Repo.Migrations.RemoveFields do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      remove :description
    end
  end
end
