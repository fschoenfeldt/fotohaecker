defmodule Fotohaecker.TagDetection.NoDetection do
  @moduledoc """
  Fallback module when no detection is enabled via config.
  """

  @behaviour Fotohaecker.TagDetection
  alias Fotohaecker.TagDetection

  @impl TagDetection
  def caption(_image) do
    {:ok, nil}
  end

  @impl TagDetection
  def tags(_image) do
    {:ok, []}
  end
end
