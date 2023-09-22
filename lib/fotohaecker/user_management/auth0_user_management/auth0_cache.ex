defmodule Fotohaecker.UserManagement.Auth0UserManagement.Auth0Cache do
  @moduledoc """
  Cache for Auth0 users to reduce the number of requests to Auth0 Management API.
  """

  alias Fotohaecker.UserManagement.Auth0UserManagement.Auth0Management
  use Agent
  require Logger

  def start_link(_initial_value) do
    Agent.start_link(
      fn ->
        # credo:disable-for-next-line
        case Auth0Management.get_all() do
          {:ok, users} ->
            {:ok, Enum.map(users, &interesting_auth0_fields/1)}

          _result ->
            Logger.warning(
              "Auth0Cache: error fetching users from auth0, initial user cache will be empty"
            )

            {:ok, []}
        end
      end,
      name: __MODULE__
    )
  end

  @doc """
  List all users in the cache.

  ## Example

    iex> Auth0Cache.get_all()
    [
      %{
        id: "auth0|5f0a3a5a7b2a0d0020a3a5a7",
        name: "fotohaecker"
      },
      # …
    ]
  """
  @spec get_all() :: {:ok, list(map())}
  def get_all do
    Agent.get(__MODULE__, & &1)
  end

  @doc """
  Given an `user_id`, return the user from the cache.

  ## Example

      iex> Auth0Cache.get("auth0|5f0a3a5a7b2a0d0020a3a5a7")
      {:ok, %{
        id: "auth0|5f0a3a5a7b2a0d0020a3a5a7",
        name: "fotohaecker"
      }}

      iex> Auth0Cache.get("nonexistent user")
      {:error, %{
        "statusCode" => 404,
        "error" => "Not Found",
        "message" => "User not found"
      }}
  """
  @spec get(String.t()) :: {:error, map()} | {:ok, map()}
  def get(user_id) do
    maybe_user_found =
      Agent.get(__MODULE__, fn {:ok, users} ->
        Enum.find(users, &user_match(user_id, &1))
      end)

    if maybe_user_found do
      {:ok, maybe_user_found}
    else
      Logger.info("User #{user_id} not found in cache, trying to resolve user")

      # TODO: DRY, same as update/1
      maybe_user = Auth0Management.get(user_id)

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

    iex> Auth0Cache.get("auth0|5f0a3a5a7b2a0d0020a3a5a7")
    nil

    iex> Auth0Cache.add("auth0|5f0a3a5a7b2a0d0020a3a5a7")
    :ok

    iex> Auth0Cache.get("auth0|5f0a3a5a7b2a0d0020a3a5a7")
    %{
      id: "auth0|5f0a3a5a7b2a0d0020a3a5a7",
      name: "fotohaecker"
    }
  """
  @spec add(String.t()) :: {:error, map()} | {:ok, map()}
  def add(user_id) do
    maybe_user = Auth0Management.get(user_id)

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

  defp maybe_add_user({:ok, users}, user_id, user) do
    maybe_user_found = Enum.find(users, &user_match(user_id, &1))

    if maybe_user_found == nil do
      {:ok, [interesting_auth0_fields(user) | users]}
    else
      {:ok, users}
    end
  end

  defp maybe_delete_user({:ok, users}, user_id) do
    {:ok, Enum.reject(users, &user_match(user_id, &1))}
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
