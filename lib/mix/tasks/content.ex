defmodule Mix.Tasks.Content do
  @shortdoc "utils for working with content"
  @moduledoc """
  Utils for working with content.

  It expects the action to be performed as the first argument, followed by
  any arguments that action requires.

  ## Actions

      mix content delete <photo_id>
      mix content list
  """

  use Mix.Task

  alias Fotohaecker.Content

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    handle!(args)
  end

  defp handle!(["delete", photo_id] = _args) do
    photo =
      photo_id
      |> String.to_integer()
      |> Content.get_photo!()

    if confirm?("""
       confirm deleting photo:

       title: #{inspect(photo.title)}
       file_name: #{inspect(photo.file_name)}
       url: #{url(photo)}
       inserted_at: #{inspect(photo.inserted_at)}

       (Y/n)
       """) do
      Content.delete_photo(photo)
      |> case do
        {:ok, _} ->
          IO.puts("deleted photo")

        {:error, e} ->
          IO.puts("error deleting photo")
          IO.inspect(e)
      end
    else
      IO.puts("aborting")
    end
  end

  defp handle!(["list"] = _args) do
    Enum.each(Content.list_photos(), fn photo ->
      IO.puts("""
      id: #{photo.id}
      title: #{photo.title}
      file_name: #{photo.file_name}
      url: #{url(photo)}
      inserted_at: #{photo.inserted_at}
      """)
    end)
  end

  defp handle!(_args) do
    raise "usage: mix content delete <photo_id>"
  end

  defp confirm?(prompt) do
    IO.puts(prompt)

    response =
      IO.gets("")
      |> String.trim()
      |> String.downcase()

    response in ["", "y"]
  end

  defp url(%Content.Photo{} = photo) do
    FotohaeckerWeb.Router.Helpers.static_url(
      FotohaeckerWeb.Endpoint,
      "/uploads/#{photo.file_name}_og#{photo.extension}"
    )
  end
end
