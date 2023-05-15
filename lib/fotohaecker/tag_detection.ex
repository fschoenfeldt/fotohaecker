defmodule Fotohaecker.TagDetection do
  @moduledoc """
  This module provides tag detection functionality for images.

  It implements the `Fotohaecker.TagDetection.TagDetectionBehaviour` behaviour, which defines the interface for tag detection and caption generation.
  """

  @behaviour Fotohaecker.TagDetection.TagDetectionBehaviour
  alias Fotohaecker.TagDetection.TagDetectionBehaviour

  @impl TagDetectionBehaviour
  @doc """
  Returns a list of tags detected in the image at the specified path.

  Parameters:
  - `image_path` (string): The path to the image file.

  Returns:
  A list of strings representing the tags detected in the image.
  """
  def tags(image_path) do
    implementation().tags(image_path)
  end

  @impl TagDetectionBehaviour
  @doc """
  Generates a caption for the image at the specified path.

  Parameters:
  - `image_path` (string): The path to the image file.

  Returns:
  A string representing a caption for the image.
  """
  def caption(image_path) do
    implementation().caption(image_path)
  end

  defp implementation,
    do:
      Application.get_env(
        :fotohaecker,
        __MODULE__,
        Fotohaecker.TagDetection.NoDetection
      )
end
