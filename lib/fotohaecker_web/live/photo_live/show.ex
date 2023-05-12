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
        <div class="md:grid gap-8 grid-cols-12">
          <.download_link class="col-span-8 bg-[#17181b] md:py-8" href={path} photo={@photo}>
            <img
              class="w-auto max-h-[calc(100vh-10rem)] mx-auto"
              src={preview_path}
              alt={gettext("photo %{title} on Fotohäcker", %{title: title})}
            />
          </.download_link>
          <div class="col-span-4 m-4 md:pt-4 space-y-4">
            <.back_button />
            <h1 class=""><%= title %></h1>

            <p class="text-sm text-gray-800" x-data x-text={alpine_format_date(@photo.inserted_at)}>
              <%= gettext("uploaded on %{date}", %{date: @photo.inserted_at}) %>
            </p>
            <.download_link class="btn btn--green flex gap-2 w-max" href={path} photo={@photo}>
              <Heroicons.arrow_down_tray class="w-6 h-6 stroke-white" /> <%= gettext("Download") %>
            </.download_link>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp alpine_format_date(%NaiveDateTime{} = date) do
    js_date = "${new Date('#{date}').toLocaleDateString()}"
    "`#{gettext("uploaded on %{date}", %{date: js_date})}`"
  end

  slot(:inner_block, required: true)
  attr(:class, :string)
  attr(:href, :string, required: true)
  attr(:photo, Content.Photo, required: true)
  attr(:target, :string, default: "_blank")

  defp download_link(assigns) do
    ~H"""
    <.link
      class={@class}
      href={@href}
      target={@target}
      title={gettext("download the photo %{title} from Fotohäcker", %{title: @photo.title})}
    >
      <%= render_slot(@inner_block) %>
    </.link>
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
