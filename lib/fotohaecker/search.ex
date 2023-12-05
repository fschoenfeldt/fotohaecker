defmodule Fotohaecker.Search do
  @moduledoc """
  The Search context.
  """
  require Logger
  alias Fotohaecker.Content.Photo
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
      iex> [result] = Fotohaecker.Search.search!("search")
      iex> result.photo.title
      "search"

      iex> Mox.stub(Fotohaecker.UserManagement.UserManagementMock, :search!, fn _term ->
      ...>  [%{id: "auth0|123", nickname: "test"}]
      ...> end)
      iex> [result] = Fotohaecker.Search.search!("test")
      iex> result.user.nickname
      "test"

      iex> Mox.expect(Fotohaecker.UserManagement.UserManagementMock, :search!, fn _term ->
      ...>  [%{id: "auth0|777", nickname: "search"}]
      ...> end)
      iex> %{title: "search", file_name: "search", tags: [], extension: ".jpg"}
      ...> |> Fotohaecker.Content.create_photo()
      iex> results = Fotohaecker.Search.search!("search")
      iex> results |> length()
      2
  """
  @spec search!(String.t()) :: [map()] | []
  def search!("") do
    []
  end

  def search!(term) do
    []
    |> with_users!(term)
    |> with_photos!(term)
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

  defp with_users!(search_results, "" = _term), do: search_results

  defp with_users!(search_results, query) do
    cond do
      String.trim(query) == "" ->
        with_users!(search_results, "")

      UserManagement.is_implemented?() ->
        query
        |> UserManagement.search!()
        |> to_search_results()
        |> Kernel.++(search_results)

      true ->
        Logger.debug("UserManagement is not implemented, skipping user search")

        search_results
    end
  end

  defp with_photos!(search_results, "" = _term), do: search_results

  defp with_photos!(search_results, term) do
    if String.trim(term) == "" do
      with_photos!(search_results, "")
    else
      term
      |> Fotohaecker.Content.search_photos()
      |> to_search_results()
      |> Kernel.++(search_results)
    end
  end

  defp to_search_results(results) do
    Enum.map(
      results,
      &to_search_result/1
    )
  end

  defp to_search_result(%Photo{} = photo) do
    %__MODULE__{
      type: :photo,
      photo: photo
    }
  end

  defp to_search_result(user) when is_map(user) do
    %__MODULE__{
      type: :user,
      user: user
    }
  end
end
