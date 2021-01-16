defmodule FotohaeckerWeb.PageLive do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content

  @impl true
  def mount(_params, _session, socket) do
    # initial assigns
    socket =
      socket
      |> assign(query: "")
      |> assign(results: %{})
      |> assign(photos: [])

    # assign additional when websocket conn is established
    socket =
      if connected?(socket) do
        socket |> assign_photos()
      else
        socket
      end

    {:ok, socket}
  end

  defp assign_photos(socket) do
    photos = Content.list_photos()

    assign(socket, photos: photos)
  end
end
