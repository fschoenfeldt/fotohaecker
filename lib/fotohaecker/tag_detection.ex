defmodule Fotohaecker.TagDetection do
  @moduledoc """
  Behaviour for tag detection.
  """
  require Logger

  @doc """
  Detects tags in a given image.
  """
  @callback tags(image :: String.t()) :: {:ok, [String.t()]} | {:error, String.t()}
  @callback caption(image :: String.t()) :: {:ok, String.t()} | {:ok, nil} | {:error, String.t()}

  @spec detect_tags(String.t()) :: {:ok, [String.t()]} | {:error, String.t()}
  def detect_tags(image), do: module().tags(image)

  @spec detect_caption(String.t()) :: {:ok, String.t()} | {:ok, nil} | {:error, String.t()}
  def detect_caption(image), do: module().caption(image)

  defp module do
    case Application.get_env(:fotohaecker, __MODULE__) do
      %{implementation: module} ->
        module

      _config_not_set ->
        Logger.info(
          "Info: No tag/caption detection module configured. Please set the key in your envrc."
        )

        # TODO implement a dummy module
        Fotohaecker.TagDetection.NoDetection
    end
  end

  # Fotohaecker.TagDetection.detect_tags("")
end
