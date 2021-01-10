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

alias Fotohaecker.Repo
alias Fotohaecker.Accounts.User
alias Fotohaecker.Content.Photo

{:ok, now } = DateTime.now("Etc/UTC")
now = DateTime.truncate(now, :second)

%User{
  email: "admin@fotohaeck.er",
  name: "admin",
  password: "12345"
} |> Repo.insert!()

%User{
  email: "another_user@fotohaeck.er",
  name: "another_user",
  password: "12345"
} |> Repo.insert!()

%Photo {
  title: "Testfoto",
  description: "Lorem Ipsum Dolor Sit Amet",
  path: "testfoto",
  tags: ["zum", "testen"],
  uploaded: now,
  user_id: 1
} |> Repo.insert!()

%Photo {
  title: "Testfoto 2",
  description: "Lorem Ipsum Dolor Sit Amet",
  path: "testfoto",
  tags: ["zum", "testen"],
  uploaded: now,
  user_id: 2
} |> Repo.insert!()
