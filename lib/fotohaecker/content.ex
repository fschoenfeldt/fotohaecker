defmodule Fotohaecker.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Fotohaecker.Repo

  alias Fotohaecker.Content.Photo

  @doc """
  lists photos.

  ## Examples

      iex> list_photos()
      [%Fotohaecker.Content.Photo{}, ...]

      iex> list_photos(1)
      [%Fotohaecker.Content.Photo{}]

  """
  @spec list_photos(integer, integer, atom()) :: [Photo.t()] | []
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

  def photos_count do
    query = from p in Photo, select: count(p.id)
    Repo.one(query)
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
  Deletes a photo.

  ## Examples

      iex> delete_photo(photo)
      {:ok, %Fotohaecker.Content.Photo{}}

      iex> delete_photo(photo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_photo(%Photo{} = photo) do
    # TODO delete photo file after deleting photo
    # :ok = File.rm(Photo.gen_path(photo.file_name) <> photo.extension)
    # :ok = File.rm(Photo.gen_path(photo.file_name) <> "_thumb" <> photo.extension)
    Repo.delete(photo)
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
