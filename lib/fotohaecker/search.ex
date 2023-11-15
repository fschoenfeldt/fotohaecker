defmodule Fotohaecker.Search do
  @moduledoc """
  The Search context.
  """
  require Logger
  alias Fotohaecker.UserManagement

  @type t :: %__MODULE__{
          type: :photo | :user | nil,
          photo: map() | nil,
          user: map() | nil
        }

  defstruct type: nil, photo: nil, user: nil

  @doc """
  Search for users and photos.

  ## Examples
      iex> %{title: "search", file_name: "search", tags: [], extension: ".jpg"} |> Fotohaecker.Content.create_photo()
      iex> [result] = Fotohaecker.Search.search("search")
      iex> result.photo.title
      "search"

      iex> Mox.stub(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
      ...>  {:ok, [%{id: "auth0|123", nickname: "test"}]}
      ...> end)
      iex> [result] = Fotohaecker.Search.search("test")
      iex> result.user.nickname
      "test"

      iex> Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :get_all, fn ->
      ...>  {:ok, [%{id: "auth0|777", nickname: "search"}]}
      ...> end)
      iex> %{title: "search", file_name: "search", tags: [], extension: ".jpg"}
      ...> |> Fotohaecker.Content.create_photo()
      iex> results = Fotohaecker.Search.search("search")
      iex> results |> length()
      2
  """
  @spec search(String.t()) :: [map()] | []
  def search(query) do
    []
    |> with_users(query)
    |> with_photos(query)
  end

  defp with_users(search_results, query) do
    with true <- UserManagement.is_implemented?(),
         {:ok, users} <- UserManagement.get_all() do
      users
      |> Enum.filter(fn user ->
        String.contains?(user.nickname, query) or String.contains?(user.id, query)
      end)
      |> Enum.map(
        &%__MODULE__{
          type: :user,
          user: &1
        }
      )
      |> Kernel.++(search_results)
    else
      _not_implemented_or_error ->
        Logger.debug(
          "UserManagement is not implemented or an error occurred, skipping user search"
        )

        search_results
    end
  end

  defp with_photos(search_results, query) do
    search_results ++
      (query
       |> Fotohaecker.Content.search_photos()
       |> Enum.map(
         &%__MODULE__{
           type: :photo,
           photo: &1
         }
       ))
  end
end
