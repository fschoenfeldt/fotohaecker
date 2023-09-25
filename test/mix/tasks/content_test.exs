defmodule Mix.Tasks.ContentTest do
  # credo:disable-for-next-line
  use Fotohaecker.DataCase

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

    # is skipped because right now, it reads the actual file system not a test directory
    @tag :skip
    test "lists orphaned photo files with `mix content list orphaned`" do
      photo = photo_fixture()

      photo_paths = Fotohaecker.Content.photo_paths(photo)

      # write empty binary files to the destination paths
      Enum.each(photo_paths, fn path ->
        File.write!(path, "")
      end)

      # write empty binary file that will be listed as orphaned
      "this_is_orphaned"
      |> Fotohaecker.Content.Photo.gen_path()
      |> File.write!("")

      actual =
        capture_io(fn ->
          Content.run(["list", "orphaned"])
        end)

      expected = "this_is_orphaned"

      assert actual == expected
    end

    # TODO test "deletes photo with `mix content delete orphaned`"

    test "deletes photo with `mix content delete <photo_id>`" do
      photo =
        photo_fixture(%{
          user_id: "1337"
        })

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
