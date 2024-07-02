defmodule FotohaeckerWeb.PhotoJSON do
  @behaviour FotohaeckerWeb.SchemaBehaviour

  alias Fotohaecker.Content.Photo
  alias Fotohaecker.Search

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

  @doc """
  Schema for usage in swagger

  # TODO: enforce schema function by using elixirs behaviour
  """
  def schema do
    use PhoenixSwagger

    swagger_schema do
      title("Photo")
      description("A photo")

      properties do
        id(:integer, "Photo ID", required: true)
        title(:string, "Photo title", required: true)
        tags(array(:string), "Photo tags")

        links(
          Schema.new do
            property(:html, :string, "HTML link to photo")
          end
        )

        urls(
          Schema.new do
            property(:thumb1x, :string, "Small Thumbnail URL")
            property(:thumb2x, :string, "Medium Thumb URL")
            property(:thumb3x, :string, "Large Thumb URL")
            property(:raw, :string, "Original photo URL")
            property(:full, :string, "Full size photo URL")
          end
        )

        description(:string, "Photo description")
        url(:string, "Photo URL", required: true)
        inserted_at(:string, "Creation timestamp", format: "date-time")
        updated_at(:string, "Last update timestamp", format: "date-time")
      end
    end
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
