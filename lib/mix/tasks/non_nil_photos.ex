defmodule Mix.Tasks.NonNilPhotos do
  @shortdoc "update all existing photos that have `tags: nil` to `tags: []`"
  @moduledoc @shortdoc

  use Mix.Task
  import Ecto.Query
  alias Fotohaecker.Content.Photo

  @requirements ["app.start"]

  @impl Mix.Task
  def run(_args) do
    # update all existing photos that have `tags: nil` to `tags: []`
    query = from(p in Photo, where: is_nil(p.tags), update: [set: [tags: []]])

    Fotohaecker.Repo.update_all(
      query,
      []
    )
  end
end
