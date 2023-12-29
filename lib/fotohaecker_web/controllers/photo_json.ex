defmodule FotohaeckerWeb.PhotoJSON do
  alias Fotohaecker.Search
  alias Fotohaecker.Content.Photo

  @doc """
  Renders a list of photos.
  """
  def index(%{photos: photos}) do
    %{data: for(photo <- photos, do: data(photo))}
  end

  @doc """
  Renders a single photo.
  """
  def show(%{photo: photo}) do
    %{
      data: data(photo)
    }
  end

  # Instead of deriving the Jason.Encoder protocol for the Photo struct,
  # we can also define a data/1 function that returns a map with the
  # desired fields.
  defp data(%Photo{} = photo) do
    %{
      id: photo.id,
      title: photo.title,
      tags: photo.tags,
      links: %{html: FotohaeckerWeb.LiveHelpers.photo_url(photo.id)},
      urls: FotohaeckerWeb.LiveHelpers.photo_urls(photo)
    }
  end

  defp data(%Search{photo: photo}) do
    data(photo)
  end
end
