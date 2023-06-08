defmodule Fotohaecker.TagDetectionTest do
  use ExUnit.Case, async: true
  alias Fotohaecker.TagDetection
  import Mox

  setup :verify_on_exit!

  @image_mock_path "test/e2e/fixtures/photo_fixture.jpg"

  describe "tags/1" do
    test "returns tags for image" do
      expect(Fotohaecker.TagDetection.TagDetectionMock, :tags, fn _path ->
        ["test", "tag"]
      end)

      actual = TagDetection.tags(@image_mock_path)
      expected = ["test", "tag"]

      assert actual == expected
    end

    test "returns empty tags for image" do
      expect(Fotohaecker.TagDetection.TagDetectionMock, :tags, fn _path ->
        []
      end)

      actual = TagDetection.tags(@image_mock_path)
      expected = []

      assert actual == expected
    end

    test "returns error" do
      expect(Fotohaecker.TagDetection.TagDetectionMock, :tags, fn _path ->
        {:error, "error"}
      end)

      actual = TagDetection.tags(@image_mock_path)
      expected = {:error, "error"}

      assert actual == expected
    end
  end

  describe "caption/1" do
    test "returns caption for image" do
      expect(Fotohaecker.TagDetection.TagDetectionMock, :caption, fn _path ->
        "test caption"
      end)

      actual = TagDetection.caption(@image_mock_path)
      expected = "test caption"

      assert actual == expected
    end

    test "returns empty caption for image" do
      expect(Fotohaecker.TagDetection.TagDetectionMock, :caption, fn _path ->
        ""
      end)

      actual = TagDetection.caption(@image_mock_path)
      expected = ""

      assert actual == expected
    end

    test "returns error" do
      expect(Fotohaecker.TagDetection.TagDetectionMock, :caption, fn _path ->
        {:error, "error"}
      end)

      actual = TagDetection.caption(@image_mock_path)
      expected = {:error, "error"}

      assert actual == expected
    end
  end
end
