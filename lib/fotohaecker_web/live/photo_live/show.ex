defmodule FotohaeckerWeb.PhotoLive.Show do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content

  defmodule PhotoNotFoundError do
    defexception message: dgettext("errors", "photo not found"), plug_status: 404
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _what, socket) do
    case Content.get_photo(id) do
      %Content.Photo{} = photo ->
        {:noreply,
         socket
         |> assign(:page_title, photo.title)
         |> assign(:photo, photo)}

      nil ->
        raise PhotoNotFoundError
        {:noreply, socket}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="photo">
      <%= with _id          <- @photo.id,
               title        <- @photo.title,
               file_name    <- @photo.file_name,
               extension    <- @photo.extension,
               path         <- Routes.static_path(FotohaeckerWeb.Endpoint,
                                                  "/uploads/#{file_name}_og#{extension}"),
               preview_path <- Routes.static_path(FotohaeckerWeb.Endpoint,
                                                  "/uploads/#{file_name}_preview#{extension}") do %>
        <div class="grid gap-8 grid-cols-12">
          <a
            class="col-span-8"
            href={path}
            target="_blank"
            title={gettext("download the photo %{title} from Fotohäcker", %{title: title})}
          >
            <img
              class="max-w-[70rem] w-full"
              src={preview_path}
              alt={gettext("photo %{title} on Fotohäcker", %{title: title})}
            />
          </a>
          <div class="col-span-4 self-end">
            <.back_button />
            <h1 class=""><%= title %></h1>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp back_button(assigns) do
    ~H"""
    <%!-- #TODO: href should be set --%>
    <.link
      phx-click="goto"
      phx-keydown="goto"
      phx-key="Enter"
      phx-value-target="index"
      class="flex text-black fill-black"
    >
      <svg
        class="w-6 h-6"
        fill="black"
        stroke="black"
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
      <%= gettext("back") %>
    </.link>
    """
  end

  @impl true
  def handle_event("goto", %{"target" => "index"}, socket) do
    {:noreply, push_navigate(socket, to: home_route())}
  end
end
