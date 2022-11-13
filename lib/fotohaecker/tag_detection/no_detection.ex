defmodule Fotohaecker.TagDetection.NoDetection do
  @moduledoc """
  Fallback module when no detection is enabled via config.
  """

  @behaviour Fotohaecker.TagDetection.TagDetectionBehaviour
  alias Fotohaecker.TagDetection.TagDetectionBehaviour

  @impl TagDetectionBehaviour
  def caption(_image_path) do
    {:ok, nil}
  end

  @impl TagDetectionBehaviour
  def tags(_image_path) do
    {:ok, []}
  end
end
