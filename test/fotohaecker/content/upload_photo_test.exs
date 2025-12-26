defmodule Fotohaecker.UploadPhotoTest do
  use Fotohaecker.DataCase, async: true

  alias Fotohaecker.Content.UploadPhoto
  import UploadPhoto
  doctest Fotohaecker.Content.UploadPhoto

  # FIXME: right now, this function is not testable
  #        because it uses Phoenix.LiveView.consume_uploaded_entries/3 which
  #        is not available in the test environment
  # describe "validate_and_upload_photo/3" do
  #   test "works with valid photo" do
  #     submission_params = %{
  #       title: "a title",
  #       file_name: "file_name",
  #       extension: ".jpg",
  #       user_id: "auth0|123",
  #       tags: []
  #     }

  #     socket = %Phoenix.LiveView.Socket{}
  #     dest = "dest.jpg"

  #     actual =
  #       validate_and_upload_photo(
  #         submission_params,
  #         socket,
  #         dest
  #       )

  #     expected = {:ok, "dest.jpg"}

  #     assert actual == expected
  #   end
  # end
end
