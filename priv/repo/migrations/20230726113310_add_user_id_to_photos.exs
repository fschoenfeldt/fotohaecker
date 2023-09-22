defmodule Fotohaecker.Repo.Migrations.AddUserIdToPhotos do
  use Ecto.Migration

  def change do
    alter table(:photos) do
      add :user_id, :string
    end
  end
end
