defmodule Fotohaecker.TagDetection.TagDetectionBehaviour do
  @moduledoc """
  Behaviour for tag detection.
  """

  @callback tags(image :: String.t()) :: {:ok, [String.t()]} | {:ok, nil} | {:error, String.t()}
  @callback caption(image :: String.t()) :: {:ok, String.t()} | {:ok, nil} | {:error, String.t()}
end
