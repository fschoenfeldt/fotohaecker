defmodule Fotohaecker.Auth0Cache do
  @moduledoc """
  Cache for Auth0 users to reduce the number of requests to Auth0 Management API.
  """

  alias Fotohaecker.Auth0Management
  use Agent
  require Logger

  def start_link(_initial_value) do
    Agent.start_link(
      fn ->
        case Auth0Management.users_get() do
          {:ok, users} ->
            Enum.map(users, &interesting_auth0_fields/1)

          _ ->
            Logger.warning("error fetching users from auth0, user cache will be empty")
            []
        end
      end,
      name: __MODULE__
    )
  end

  @doc """
  List all users in the cache.

  ## Example

    iex> Auth0Cache.users()
    [
      %{
        id: "auth0|5f0a3a5a7b2a0d0020a3a5a7",
        name: "fotohaecker"
      },
      # …
    ]
  """
  @spec users() :: list(map())
  def users do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Given an `user_id`, return the user from the cache.

  ## Example

      iex> Auth0Cache.user("auth0|5f0a3a5a7b2a0d0020a3a5a7")
      {:ok, %{
        id: "auth0|5f0a3a5a7b2a0d0020a3a5a7",
        name: "fotohaecker"
      }}

      iex> Auth0Cache.user("nonexistent user")
      {:error, %{
        "statusCode" => 404,
        "error" => "Not Found",
        "message" => "User not found"
      }}
  """
  @spec user(String.t()) :: {:error, map()} | {:ok, map()}
  def user(user_id) do
    maybe_user_found =
      Agent.get(__MODULE__, fn users ->
        Enum.find(users, &user_match(user_id, &1))
      end)

    if maybe_user_found do
      {:ok, maybe_user_found}
    else
      Logger.info("User #{user_id} not found in cache, trying to resolve user")

      # TODO: DRY
      maybe_user = Auth0Management.user_get(user_id)

      case maybe_user do
        {:ok, user} ->
          Agent.update(__MODULE__, &maybe_add_user(&1, user_id, user))

          {:ok, interesting_auth0_fields(user)}

        {:error, reason} ->
          Logger.warning("error fetching user #{user_id} from auth0")
          Logger.warning(reason)
          {:error, reason}
      end
    end
  end

  @doc """
  Given an `user_id`, update the cache with the user from Auth0 if it is not already in the cache.

  ## Example

    iex> Auth0Cache.user("auth0|5f0a3a5a7b2a0d0020a3a5a7")
    nil

    iex> Auth0Cache.update("auth0|5f0a3a5a7b2a0d0020a3a5a7")
    :ok

    iex> Auth0Cache.user("auth0|5f0a3a5a7b2a0d0020a3a5a7")
    %{
      id: "auth0|5f0a3a5a7b2a0d0020a3a5a7",
      name: "fotohaecker"
    }
  """
  @spec update(String.t()) :: {:error, map()} | {:ok, map()}
  def update(user_id) do
    maybe_user = Auth0Management.user_get(user_id)

    case maybe_user do
      {:ok, user} ->
        Agent.update(__MODULE__, &maybe_add_user(&1, user_id, user))

        {:ok, interesting_auth0_fields(user)}

      {:error, reason} ->
        Logger.warning("error fetching user #{user_id} from auth0")
        Logger.warning(reason)
        {:error, reason}
    end
  end

  def delete(user_id) do
    Agent.update(__MODULE__, &maybe_delete_user(&1, user_id))
  end

  defp maybe_add_user(users, user_id, user) do
    maybe_user_found = Enum.find(users, &user_match(user_id, &1))

    if maybe_user_found == nil do
      [interesting_auth0_fields(user) | users]
    else
      users
    end
  end

  defp maybe_delete_user(users, user_id) do
    Enum.reject(users, &user_match(user_id, &1))
  end

  defp user_match(user_id, user), do: user.id == user_id

  defp interesting_auth0_fields(auth_0_user) do
    %{
      id: auth_0_user["user_id"],
      nickname: auth_0_user["nickname"],
      picture: auth_0_user["picture"]
    }
  end
end
