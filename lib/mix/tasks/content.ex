defmodule Mix.Tasks.Content do
  @shortdoc "utils for working with content"
  @moduledoc """
  Utils for working with content.

  It expects the action to be performed as the first argument, followed by
  any arguments that action requires.

  ## Actions

      mix content delete <photo_id | orphaned>
      mix content list [orphaned]
  """

  use Mix.Task

  alias Fotohaecker.Content

  @requirements ["app.start"]

  @impl Mix.Task
  def run(args) do
    handle!(args)
  end

  defp handle!(["delete", "orphaned", "-y"] = _args) do
    orphaned = list_orphaned()

    orphaned
    |> Enum.each(fn file_name ->
      IO.puts("deleting file: #{inspect(file_name)}")
      File.rm!(Path.join(photo_dir(), file_name))
    end)
  end

  defp handle!(["delete", "orphaned"] = _args) do
    orphaned = list_orphaned()

    if confirm?("""
       confirm deleting #{length(orphaned)} orphaned photos

       (Y/n)
       """) do
      handle!(["delete", "orphaned", "-y"])
    else
      IO.puts("aborting")
    end
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
      Content.delete_photo(photo, photo.user_id)
      |> case do
        {:ok, _} ->
          IO.puts("deleted photo")

        {:error, e} ->
          IO.puts("error deleting photo")
          IO.puts(e)
      end
    else
      IO.puts("aborting")
    end
  end

  defp handle!(["list", "orphaned"] = _args) do
    list_orphaned() |> Enum.each(&IO.puts/1)
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
    raise """
    usage:
      mix content delete <photo_id | orphaned>
      mix content list [orphaned]
    """
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

  defp list_orphaned do
    photo_file_names =
      1_000_000
      |> Content.list_photos()
      |> Enum.map(& &1.file_name)

    all_files =
      photo_dir()
      |> File.ls!()

    Enum.reject(all_files, fn file ->
      Enum.find(photo_file_names, &(file =~ &1))
    end)
  end

  defp photo_dir(),
    do:
      [
        :code.priv_dir(:fotohaecker),
        "static",
        "uploads"
      ]
      |> Path.join()
end
