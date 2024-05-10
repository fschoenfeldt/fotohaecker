defmodule Fotohaecker.Content.UploadPhoto do
  @moduledoc """
  Uploads a photo and creates a photo record.
  """
  require Logger

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo

  @doc """
  Adds the photo fields to the submission params.

  ## Examples

      iex> add_photo_fields(%{title: "a title"}, "file_name", ".jpg", 1)
      %{title: "a title", file_name: "file_name", extension: ".jpg", user_id: 1}

  """
  def add_photo_fields(submission_params, file_name, extension, current_user_id) do
    submission_params
    |> Map.put(:file_name, file_name)
    |> Map.put(:extension, extension)
    |> Map.put(:user_id, current_user_id)
  end

  @doc """
  Validates and uploads a photo.
  """
  def validate_and_upload_photo(submission_params, socket, dest) do
    case Content.change_photo(%Photo{}, submission_params) do
      %Ecto.Changeset{valid?: false} = changeset ->
        message =
          changeset
          |> FotohaeckerWeb.ErrorHelpers.error_messages()
          |> inspect()

        {:error, message}

      %Ecto.Changeset{valid?: true} ->
        upload_photo(socket, dest, submission_params)
    end
  end

  defp upload_photo(socket, dest, submission_params) do
    Phoenix.LiveView.consume_uploaded_entries(socket, :photo, fn %{path: path}, _entry ->
      File.cp!(path, dest)
      compress_and_create_photo(dest, submission_params)
    end)
  end

  defp compress_and_create_photo(dest, submission_params) do
    task_compress =
      Task.async(fn ->
        NodeJS.call("compress", [
          Photo.gen_path(submission_params.file_name),
          submission_params.extension
        ])
      end)

    case Task.await(task_compress, 10_000) do
      {:ok, _} ->
        File.rm!(dest)
        Content.create_photo(submission_params)

      {:error, reason} ->
        Logger.error("error compressing photo: #{inspect(reason)}")
        message = Gettext.dgettext(FotohaeckerWeb.Gettext, "errors", "compression failed")
        {:error, message}
    end
  end

  @doc """
  Returns the file extension from the client type.

  ## Examples

      iex> extension_from_type!("image/jpeg")
      ".jpg"
      iex> extension_from_type!("unknown")
      ** (RuntimeError) Unsupported Type. This error shouldn't happen as it's configured via LiveView Upload.
  """
  def extension_from_type!("image/jpeg"), do: ".jpg"

  def extension_from_type!(_unsupported_type),
    do:
      raise(
        "Unsupported Type. This error shouldn't happen as it's configured via LiveView Upload."
      )
end
