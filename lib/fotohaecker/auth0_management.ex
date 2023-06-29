defmodule Fotohaecker.Auth0Management do
  @moduledoc """
  Module to handle Auth0 Management API calls
  """

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

  defp user_logs_request(_id, {:error, _reason} = error) do
    error
  end

  defp user_logs_request(id, {:ok, headers}) do
    domain = System.get_env("AUTH0_DOMAIN")
    url = "https://#{domain}/api/v2/users/#{id}/logs"

    HTTPoison.get(url, headers)
  end

  defp user_delete_account_request(_id, {:error, _reason} = error) do
    error
  end

  defp user_delete_account_request(id, {:ok, headers}) do
    domain = System.get_env("AUTH0_DOMAIN")
    url = "https://#{domain}/api/v2/users/#{id}"

    HTTPoison.delete(url, headers)
  end

  @doc """
  Get user logs
  """
  @spec user_logs(map) :: {:ok, map} | {:error, term}
  def user_logs(%{id: user_id} = _user) do
    user_id
    |> user_logs_request(headers())
    |> decode()
  end

  @doc """
  Delete user account
  """
  @spec user_delete_account(map) :: {:ok, map} | {:error, term}
  def user_delete_account(%{id: user_id} = _user) do
    user_delete_account_request(user_id, headers())
  end
end
