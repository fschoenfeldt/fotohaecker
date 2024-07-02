defmodule FotohaeckerWeb.PhotoController do
  use FotohaeckerWeb, :controller
  use PhoenixSwagger

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo

  action_fallback FotohaeckerWeb.FallbackController

  def swagger_definitions do
    %{
      Photo: FotohaeckerWeb.PhotoJSON.schema()
    }
  end

  swagger_path :index do
    tag("Photo")
    description("List all photos")
    response(200, "OK", Schema.ref(:Photo))
  end

  # TODO: add pagination
  # see https://github.com/fschoenfeldt/fotohaecker/issues/119

  def index(conn, _params) do
    photos = Content.list_photos()
    render(conn, :index, photos: photos)
  end

  swagger_path :show do
    tag("Photo")
    description("Get a photo by ID")

    parameters do
      id(:path, :integer, "Photo ID", required: true)
    end

    response(200, "OK", Schema.ref(:Photo))
  end

  def show(conn, %{"id" => id}) do
    with %Photo{} = photo <- Content.get_photo(id) do
      render(conn, :show, photo: photo)
    end
  end

  swagger_path :search do
    tag("Photo")
    description("Search for photos")
    deprecated(true)

    parameters do
      search(:path, :string, "Search string", required: true)
    end

    response(200, "OK", Schema.ref(:Photo))
  end

  # TODO: add pagination
  # see https://github.com/fschoenfeldt/fotohaecker/issues/119

  def search(conn, %{"search" => search}) do
    # decode uri encoded search string
    search = URI.decode(search)

    photos = Fotohaecker.Search.search!(search)
    render(conn, :index, photos: photos)
  end

  swagger_path :search_query do
    tag("Photo")
    description("Search for photos")
    deprecated(true)

    parameters do
      query(:query, :string, "Search string", required: true)
    end

    response(200, "OK", Schema.ref(:Photo))
  end

  def search_query(conn, %{"query" => search}) do
    # decode uri encoded search string
    search = URI.decode(search)

    photos = Fotohaecker.Search.search!(search)
    render(conn, :index, photos: photos)
  end

  # def create(conn, %{"photo" => photo_params}) do
  #   with {:ok, %Photo{} = photo} <- Contents.create_photo(photo_params) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", ~p"/api/photos/#{photo}")
  #     |> render(:show, photo: photo)
  #   end
  # end

  # def update(conn, %{"id" => id, "photo" => photo_params}) do
  #   photo = Contents.get_photo!(id)

  #   with {:ok, %Photo{} = photo} <- Contents.update_photo(photo, photo_params) do
  #     render(conn, :show, photo: photo)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   photo = Contents.get_photo!(id)

  #   with {:ok, %Photo{}} <- Contents.delete_photo(photo) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
