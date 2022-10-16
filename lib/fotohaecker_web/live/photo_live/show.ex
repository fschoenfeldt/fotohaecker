defmodule FotohaeckerWeb.PhotoLive.Show do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _what, socket) do
    {:noreply,
     socket
     # |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:photo, Content.get_photo!(id))}
  end

  def render(assigns) do
    ~H"""
    <div id="photo" class="h-full">
      <div class="bg"></div>
      <%!-- #TODO: href should be set --%>
      <a phx-click="goto" phx-value-target="index" class="flex text-white fill-white">
        <svg
          class="w-6 h-6"
          fill="#fff"
          stroke="#fff"
          viewBox="0 0 24 24"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M10 19l-7-7m0 0l7-7m-7 7h18"
          >
          </path>
        </svg>
        Back
      </a>
      <%= with id        <- @photo.id,
               title     <- @photo.title,
               file_name <- @photo.file_name,
               extension <- @photo.extension,
               path       <- Routes.static_path(FotohaeckerWeb.Endpoint,
                            "/images/uploads/#{file_name}#{extension}") do %>
        <h1 class="dark:text-gray-200"><%= title %></h1>
        <img src={path} alt={gettext("photo %{title} on Fotohäcker", %{title: title})} />
      <% end %>
    </div>
    """
  end

  def handle_event("goto", %{"target" => "index"}, socket) do
    {:noreply, push_navigate(socket, to: home_route())}
  end

  defp page_title(:show), do: "Show Photo"
  defp page_title(:edit), do: "Edit Photo"
end
