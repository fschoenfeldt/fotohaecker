defmodule Mix.Tasks.NonNilPhotosTest do
  # credo:disable-for-next-line
  use Fotohaecker.DataCase

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo
  alias Mix.Tasks.NonNilPhotos

  describe "run/0" do
    test "updates all existing photos that have `tags: nil` to `tags: []`" do
      photo = %Photo{tags: nil}
      # run ecto insert query because changesets refuses to insert nil
      photo_result = Repo.insert!(photo)
      NonNilPhotos.run([])

      actual = Content.get_photo!(photo_result.id).tags
      expected = []

      assert actual == expected
    end
  end
end
