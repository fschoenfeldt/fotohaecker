defmodule Fotohaecker.UploadPhotoTest do
  use Fotohaecker.DataCase, async: true

  alias Fotohaecker.Content.UploadPhoto
  import UploadPhoto
  doctest Fotohaecker.Content.UploadPhoto
end
