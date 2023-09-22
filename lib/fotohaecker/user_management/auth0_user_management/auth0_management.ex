defmodule Fotohaecker.UserManagement.Auth0UserManagement.Auth0Management do
  @moduledoc """
  Module to handle Auth0 Management API calls

  TODO: this module should be a behaviour so we can mock it in tests
  """

  alias Fotohaecker.UserManagement.Auth0UserManagement.Auth0Cache

  defp token do
    domain = System.get_env("AUTH0_DOMAIN")
    url = "https://#{domain}/oauth/token"
    audience = "https://#{domain}/api/v2/"

    url
    |> HTTPoison.post(
      {:form,
       [
         grant_type: "client_credentials",
         client_id: System.get_env("AUTH0_MANAGEMENT_CLIENT_ID"),
         client_secret: System.get_env("AUTH0_MANAGEMENT_CLIENT_SECRET"),
         audience: audience
       ]}
    )
    |> decode()
    |> get_token()
  end

  defp decode({:ok, response}), do: Jason.decode(response.body)
  defp decode(error), do: error

  defp get_token({:error, reason}), do: {:error, reason}

  defp get_token({:ok, decoded_response}),
    do: {:ok, Map.get(decoded_response, "access_token")}

  defp headers do
    case token() do
      {:ok, token} ->
        {:ok,
         %{
           "Accept" => "application/json",
           "Authorization" => "Bearer #{token}"
         }}

      {:error, _reason} = error ->
        error
    end
  end

  # defp user_logs_request(_id, {:error, _reason} = error) do
  #   error
  # end

  # defp user_logs_request(id, {:ok, headers}) do
  #   domain = System.get_env("AUTH0_DOMAIN")
  #   url = "https://#{domain}/api/v2/users/#{id}/logs"

  #   HTTPoison.get(url, headers)
  # end

  defp user_delete_account_request(_id, {:error, _reason} = error) do
    error
  end

  defp user_delete_account_request(id, {:ok, headers}) do
    domain = System.get_env("AUTH0_DOMAIN")
    url = "https://#{domain}/api/v2/users/#{id}"

    HTTPoison.delete(url, headers)
  end

  defp user_get_request(_id, {:error, _reason} = error) do
    error
  end

  defp user_get_request(id, {:ok, headers}) do
    domain = System.get_env("AUTH0_DOMAIN")
    url = "https://#{domain}/api/v2/users/#{id}"

    HTTPoison.get(url, headers)
  end

  defp users_get_request({:error, _reason} = error) do
    error
  end

  defp users_get_request({:ok, headers}) do
    domain = System.get_env("AUTH0_DOMAIN")
    url = "https://#{domain}/api/v2/users"

    HTTPoison.get(url, headers)
  end

  # @doc """
  # Get user logs
  # """
  # @spec logs(String.t()) :: {:ok, map} | {:error, term}
  # def logs(user_id) do
  #   user_id
  #   |> user_logs_request(headers())
  #   |> decode()
  # end

  @doc """
  Delete user account
  """
  @spec delete(String.t()) :: {:ok, map} | {:error, term}
  def delete(user_id) do
    case user_delete_account_request(user_id, headers()) do
      {:ok, _} ->
        # Delete all photos by user
        # TODO: dirty limit
        photos = Fotohaecker.Content.list_photos_by_user(user_id, 1000, 0)

        Auth0Cache.delete(user_id)

        {Enum.each(photos, fn photo ->
           Fotohaecker.Content.delete_photo(photo)
         end),
         %{
           user_id: user_id,
           photos: photos
         }}

      error ->
        error
    end
  end

  @doc """
  Get user
  """
  @spec get(String.t()) :: {:ok, map} | {:error, term}
  def get(user_id) do
    response =
      user_id
      |> user_get_request(headers())
      |> decode()

    # check if the returned user matches our expectations
    case response do
      {:ok, %{"name" => _name, "picture" => _picture, "nickname" => _nickname}} ->
        response

      {:ok, resp} ->
        {:error, resp}

      error ->
        error
    end
  end

  @doc """
  Get all users
  """
  def get_all do
    headers()
    |> users_get_request()
    |> decode()

    # TODO: check if the returned users matches our expectations
  end
end
