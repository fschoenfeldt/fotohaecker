defmodule Fotohaecker.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Fotohaecker.Repo

  alias Fotohaecker.Content.Photo

  require Logger

  @doc """
  lists photos.

  ## Examples

      iex> list_photos()
      [%Fotohaecker.Content.Photo{}, ...]

      iex> list_photos(1)
      [%Fotohaecker.Content.Photo{}]

  """
  @spec list_photos(
          limit :: integer(),
          offset :: integer(),
          order :: :asc_inserted_at | :desc_inserted_at
        ) :: [Fotohaecker.Content.Photo.t()] | []
  def list_photos(limit \\ 10, offset \\ 0, order \\ :desc_inserted_at)
      when is_integer(limit)
      when is_integer(offset) do
    query = list_photos_query(limit, offset, order)
    Repo.all(query)
  end

  defp list_photos_query(limit, offset, :desc_inserted_at = _order),
    do: from(p in Photo, order_by: [desc: p.inserted_at], limit: ^limit, offset: ^offset)

  defp list_photos_query(limit, offset, :asc_inserted_at = _order),
    do: from(p in Photo, order_by: [asc: p.inserted_at], limit: ^limit, offset: ^offset)

  def photos_by_user_query(user_id, limit, offset) do
    from(p in Photo,
      where: p.user_id == ^user_id,
      order_by: [desc: p.inserted_at],
      limit: ^limit,
      offset: ^offset
    )
  end

  def list_photos_by_user(user_id, limit \\ 10, offset \\ 0) do
    query = photos_by_user_query(user_id, limit, offset)
    Repo.all(query)
  end

  @doc """
  Returns a list of photos that has a matching title or tag.

  ## Examples

      iex> search_photos("tag1")
      [%Fotohaecker.Content.Photo{}]

      iex> search_photos("title1")
      [%Fotohaecker.Content.Photo{}]
  """
  def search_photos(search_query) do
    query =
      from p in Photo,
        where:
          like(p.title, ^"%#{search_query}%") or
            fragment("tags LIKE '%' || ? || '%'", ^search_query)

    Repo.all(query)
  end

  def photos_count do
    query = from(p in Photo, select: count(p.id))
    Repo.one(query)
  end

  @doc """
  Given a list of tags, returns a comma separated string of tags.

  ## Examples

      iex> from_tags(["tag1", "tag2"])
      "tag1, tag2"

  """
  def from_tags(tags) when is_list(tags) do
    Enum.join(tags, ", ")
  end

  @doc """
  Given a comma separated string of tags, returns a list of tags.

  ## Examples

      iex> to_tags("tag1, tag2")
      ["tag1", "tag2"]

  """
  def to_tags(tags_string) when is_binary(tags_string) do
    tags_string
    |> String.split(", ")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  @doc """
  Gets a single photo.

  Raises `Ecto.NoResultsError` if the Photo does not exist.

  ## Examples

      iex> get_photo!(123)
      %Photo{}

      iex> get_photo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_photo!(id), do: Repo.get!(Photo, id)

  @doc """
  Gets a single photo.

  ## Examples

      iex> get_photo(123)
      %Photo{}

      iex> get_photo(456)
      nil
  """
  def get_photo(id), do: Repo.get(Photo, id)

  @doc """
  Creates a photo.

  ## Examples

      iex> create_photo(%{field: value})
      {:ok, %Fotohaecker.Content.Photo{}}

      iex> create_photo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_photo(attrs \\ %{}) do
    %Photo{}
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a photo.

  # TODO: this function should be checking if the user is the owner of the photo!

  ## Examples

      iex> update_photo(photo, %{field: new_value})
      {:ok, %Fotohaecker.Content.Photo{}}

      iex> update_photo(photo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_photo(%Photo{} = photo, attrs) do
    photo
    |> Photo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Checks if a user is the owner of a photo. Anonymous uploads are owned by everyone.

  ## Examples

      iex> is_photo_owner?(%Photo{user_id: "auth0|123456789"}, "auth0|123456789")
      true

      iex> is_photo_owner?(%Photo{user_id: "auth0|123456789"}, "other_user")
      false

      iex> is_photo_owner?(%Photo{user_id: nil}, "auth0|123456789")
      true

      iex> is_photo_owner?(%Photo{user_id: nil}, nil)
      true
  """
  def is_photo_owner?(%Photo{} = photo, user) when is_map(user),
    do: is_photo_owner?(photo, user.id)

  def is_photo_owner?(%Photo{user_id: nil} = _photo, user_id) when is_binary(user_id),
    do: true

  def is_photo_owner?(%Photo{} = photo, user_id) when is_binary(user_id),
    do: photo.user_id == user_id

  def is_photo_owner?(%Photo{user_id: nil}, _user_or_id), do: true

  def is_photo_owner?(%Photo{} = _photo, nil), do: false

  @doc """
  Deletes a photo.

  ## Examples

      iex> delete_photo(photo, user_id)
      {:ok, %Fotohaecker.Content.Photo{}}

      iex> delete_photo(photo, user_id_that_does_not_own_photo)
      {:error, "You are not allowed to delete this photo."}

  """
  def delete_photo(%Photo{user_id: nil} = photo, _user_or_id), do: delete_photo(photo)

  def delete_photo(%Photo{} = photo, user_id) when is_binary(user_id) do
    if is_photo_owner?(photo, user_id) do
      delete_photo(photo)
    else
      {:error, "You are not allowed to delete this photo."}
    end
  end

  def delete_photo(%Photo{} = photo, user) when is_map(user), do: delete_photo(photo, user.id)

  defp delete_photo(%Photo{} = photo) do
    paths = photo_paths(photo)

    Enum.each(paths, fn path ->
      case File.rm(path) do
        :ok ->
          Logger.debug("deleted file: #{path}")

        {:error, reason} ->
          Logger.debug("error deleting file: #{path}")
          Logger.debug(reason)
      end
    end)

    Repo.delete(photo)
  end

  def photo_paths(%Photo{} = photo) do
    [
      Photo.gen_path(photo.file_name) <> "_og" <> photo.extension,
      Photo.gen_path(photo.file_name) <> "_preview" <> photo.extension,
      Photo.gen_path(photo.file_name) <> "_thumb@1x" <> photo.extension,
      Photo.gen_path(photo.file_name) <> "_thumb@2x" <> photo.extension,
      Photo.gen_path(photo.file_name) <> "_thumb@3x" <> photo.extension
    ]
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking photo changes.

  ## Examples

      iex> change_photo(photo)
      %Ecto.Changeset{data: %Fotohaecker.Content.Photo{}}

  """
  def change_photo(%Photo{} = photo, attrs \\ %{}) do
    Photo.changeset(photo, attrs)
  end
end
