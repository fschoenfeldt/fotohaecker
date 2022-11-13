defmodule Fotohaecker.TagDetection do
  @moduledoc """
  Tag detection.
  """

  use Knigge,
    behaviour: Fotohaecker.TagDetection.TagDetectionBehaviour,
    otp_app: :fotohaecker,
    default: Fotohaecker.TagDetection.NoDetection,
    delegate_at_runtime?: true
end
