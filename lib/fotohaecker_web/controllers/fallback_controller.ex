defmodule FotohaeckerWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use FotohaeckerWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, nil) do
    conn
    |> put_status(:not_found)
    |> put_view(html: FotohaeckerWeb.ErrorHTML, json: FotohaeckerWeb.ErrorJSON)
    |> render(:not_found)
  end

  # This clause handles errors returned by Ecto's insert/update/delete.
  # def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
  #   conn
  #   |> put_status(:unprocessable_entity)
  #   |> put_view(json: FotohaeckerWeb.ChangesetJSON)
  #   |> render(:error, changeset: changeset)
  # end
end
