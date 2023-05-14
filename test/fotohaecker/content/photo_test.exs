defmodule Fotohaecker.PhotoTest do
  use Fotohaecker.DataCase, async: true

  alias Fotohaecker.Content.Photo
  doctest Fotohaecker.Content.Photo

  test "gen_path/1 returns path for saving a photo" do
    assert Photo.gen_path("test.jpg") =~
             "/lib/fotohaecker/priv/static/uploads/test.jpg"
  end

  test "photos always have empty list in database" do
    raise "not implemented yet. make sure to migrate db"
  end
end
