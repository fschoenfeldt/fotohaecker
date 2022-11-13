defmodule Fotohaecker.TagDetection do
  @moduledoc """
  Tag detection.
  """

  @behaviour Fotohaecker.TagDetection.TagDetectionBehaviour
  alias Fotohaecker.TagDetection.TagDetectionBehaviour

  @impl TagDetectionBehaviour
  def tags(image_path) do
    implementation().tags(image_path)
  end

  @impl TagDetectionBehaviour
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
