defmodule Fotohaecker.PhotoTest do
  use Fotohaecker.DataCase, async: false

  alias Fotohaecker.Content.Photo
  doctest Fotohaecker.Content.Photo

  test "gen_path/1 returns path for saving a photo" do
    assert Photo.gen_path("test.jpg") =~
             "/lib/fotohaecker/priv/static/uploads/test.jpg"
  end
end
