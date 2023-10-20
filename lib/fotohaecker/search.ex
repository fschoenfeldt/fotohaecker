defmodule Fotohaecker.Search do
  @moduledoc """
  The Search context.
  """
  require Logger
  alias Fotohaecker.UserManagement

  def search(query) do
    []
    |> with_users(query)
    |> with_photos(query)
  end

  defp with_users(search_results, query) do
    if UserManagement.is_implemented?() do
      results =
        UserManagement.get_all()
        |> Enum.filter(fn user ->
          String.contains?(user.nickname, query) or String.contains?(user.id, query)
        end)
        |> Enum.map(
          &%{
            type: :user,
            user: &1
          }
        )

      search_results ++ results
    else
      Logger.debug("UserManagement is not implemented, skipping user search")
      search_results
    end
  end

  defp with_photos(search_results, query) do
    search_results ++
      (query
       |> Fotohaecker.Content.search_photos()
       |> Enum.map(
         &%{
           type: :photo,
           photo: &1
         }
       ))
  end
end
