defmodule Mix.Tasks.ContentTest do
  use Fotohaecker.DataCase, async: true

  import ExUnit.CaptureIO
  import Fotohaecker.ContentFixtures

  alias Mix.Tasks.Content

  describe "run/0" do
    test "lists photos with `mix content list`" do
      photo = photo_fixture()
      photo_two = photo_fixture()

      actual =
        capture_io(fn ->
          Content.run(["list"])
        end)

      expected = """
      id: 2
      title: #{photo_two.title}
      file_name: #{photo_two.file_name}
      url: http://localhost:4002/uploads/some_file_name_og.jpg
      inserted_at: #{photo_two.inserted_at}

      id: 1
      title: #{photo.title}
      file_name: #{photo.file_name}
      url: http://localhost:4002/uploads/some_file_name_og.jpg
      inserted_at: #{photo.inserted_at}

      """

      assert actual == expected
    end

    test "deletes photo with `mix content delete <photo_id>`" do
      photo = photo_fixture()

      photo_paths = Fotohaecker.Content.photo_paths(photo)

      # write empty binary files to the destination paths
      Enum.each(photo_paths, fn path ->
        File.write!(path, "")
      end)

      actual =
        capture_io(fn ->
          capture_io(
            "
",
            fn ->
              Content.run(["delete", "#{photo.id}"])
            end
          )
          # credo:disable-for-next-line
          |> IO.puts()
        end)

      expected = """
      confirm deleting photo:

      title: \"#{photo.title}\"
      file_name: \"#{photo.file_name}\"
      url: http://localhost:4002/uploads/some_file_name_og.jpg
      inserted_at: ~N[#{photo.inserted_at}]

      (Y/n)

      deleted photo

      """

      assert actual == expected
    end
  end
end
