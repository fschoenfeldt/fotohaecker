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
  def search("") do
    []
  end

  def search(query) do
    # TODO: consider refactoring this into the called functions
    case String.trim(query) do
      "" ->
        []

      trimmed_query ->
        []
        |> with_users(trimmed_query)
        |> with_photos(trimmed_query)
    end
  end

  @doc """
  Group search results by type.

  ## Examples
      iex> [%Search{type: :photo, photo: %{title: "search"}}, %Search{type: :user, user: %{nickname: "search"}}]
      ...> |> Fotohaecker.Search.group_by_type()
      %{
        :photo => [%Search{type: :photo, photo: %{title: "search"}}],
        :user => [%Search{type: :user, user: %{nickname: "search"}}]
      }
      iex> []
      ...> |> Fotohaecker.Search.group_by_type()
      %{}
  """
  @spec group_by_type([t()]) :: map()
  def group_by_type(search_results) do
    Enum.group_by(search_results, & &1.type)
  end

  defp with_users(search_results, query) do
    with true <- UserManagement.is_implemented?(),
         {:ok, users} <- UserManagement.get_all() do
      users
      |> Enum.filter(fn user ->
        # or String.contains?(user.id, query)
        String.contains?(user.nickname, query)
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
