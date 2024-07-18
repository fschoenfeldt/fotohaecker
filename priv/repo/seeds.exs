# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Fotohaecker.Repo.insert!(%Fotohaecker.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Fotohaecker.Content.Photo
alias Fotohaecker.Content.Recipe
alias Fotohaecker.Repo

if Mix.env() == :e2e do
  Repo.insert(%Photo{
    title: "This photo you can't delete",
    file_name: "my-first-photo",
    extension: ".jpg",
    tags: [],
    user_id: "1337",
    id: -1
  })
end

recipe = %Recipe{
  title: "My first recipe",
  description: "This is my first recipe",
  brand: "fujifilm",
  user_id: "auth0|0000",
  settings: %{}
}

if Mix.env() in [:dev, :e2e] do
  Repo.insert!(recipe)
end

photo = %Photo{
  title: "My first photo",
  file_name: "my-first-photo",
  extension: ".jpg",
  tags: [],
  recipe_id: 1
}

amount_photos =
  if Mix.env() in [:dev, :e2e] do
    1..10
  else
    [1]
  end

for _ <- amount_photos do
  Repo.insert!(photo)
end
