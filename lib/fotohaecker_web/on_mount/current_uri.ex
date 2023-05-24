defmodule FotohaeckerWeb.OnMount.CurrentURI do
  @moduledoc """
  Ensures that the current uri is available in the socket assigns.

  Inspiration: https://stackoverflow.com/a/75400129
  """

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     Phoenix.LiveView.attach_hook(
       socket,
       :save_request_path,
       :handle_params,
       &save_request_path/3
     )}
  end

  defp save_request_path(_params, url, socket),
    do: {:cont, Phoenix.Component.assign(socket, :current_uri, URI.parse(url))}
end
