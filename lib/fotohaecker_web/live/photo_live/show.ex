defmodule FotohaeckerWeb.PhotoLive.Show do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content
  alias Fotohaecker.Content.Photo

  defmodule PhotoNotFoundError do
    defexception message: dgettext("errors", "photo not found"), plug_status: 404
  end

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :editing, nil)
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
            <.title photo={@photo} editing={@editing} />
            <p class="text-sm text-gray-800" x-data x-text={alpine_format_date(@photo.inserted_at)}>
              <%= gettext("uploaded on %{date}", %{date: @photo.inserted_at}) %>
            </p>
            <.tags photo={@photo} />
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
      class="w-max px-2 -mx-2 flex gap-1 items-center text-black fill-black"
    >
      <Heroicons.arrow_left mini class="w-4 h-4" />
      <%= gettext("back") %>
    </.link>
    """
  end

  attr(:photo, Photo, required: true)
  attr(:editing, :any, required: true)

  defp title(%{editing: nil} = assigns) do
    ~H"""
    <div class="flex items-end gap-x-1">
      <h1 class="">
        <%= @photo.title %>
      </h1>
      <button
        type="button"
        class="group btn btn--dark p-1 border-none"
        phx-click="activate_edit_mode"
        phx-value-field="title"
      >
        <Heroicons.pencil_square mini class="w-4 h-4 group-hover:fill-white" />
        <div class="sr-only">
          <%= gettext("edit title") %>
        </div>
      </button>
    </div>
    """
  end

  defp title(%{editing: %{field: "title", changeset: _changeset} = _editing} = assigns) do
    ~H"""
    <.form
      :let={f}
      for={@editing.changeset}
      class="border-2 border-dashed p-2 -mx-2 md:max-w-max"
      phx-change="edit_change"
      phx-submit="edit_submit"
    >
      <label class="block" for="photo_title">
        <%= gettext("enter a new title") %>
      </label>
      <div class="flex flex-wrap items-center gap-2">
        <%!-- # TODO: focus field after activating edit mode --%>
        <input
          id="photo_title"
          class="p-2 bg-gray-100 text-2xl max-w-full"
          name="photo[title]"
          value={Map.get(@editing.photo, String.to_existing_atom(@editing.field))}
          placeholder={gettext("photo title")}
          phx-debounce="150"
          phx-window-keydown="edit_mode_keydown"
          required
        />
        <div class="flex gap-2">
          <button
            type="submit"
            class="group btn btn--dark p-1 px-2 border-none flex items-center gap-x-1"
            phx-disable-with={gettext("saving..")}
          >
            <Heroicons.check mini class="w-4 h-4 fill-gray-800 group-hover:fill-white" alt="" />
            <div class="text-gray-800 group-hover:text-white">
              <%= gettext("save") %>
            </div>
          </button>
          <button
            type="button"
            class="group btn btn--dark p-1 px-2 border-none flex items-center gap-x-1"
            phx-disable-with={gettext("canceling..")}
            phx-click="edit_mode_keydown"
            phx-value-key="Escape"
          >
            <Heroicons.no_symbol mini class="w-4 h-4 fill-gray-800 group-hover:fill-white" alt="" />
            <div class="text-gray-800 group-hover:text-white">
              <%= gettext("cancel") %>
            </div>
          </button>
        </div>
      </div>
      <%= error_tag(f, :title) %>
    </.form>
    """
  end

  defp tags(assigns) do
    ~H"""
    <%= if length(@photo.tags) == 0 do %>
      <p class="text-sm text-gray-800">
        <%= gettext("no tags") %>
      </p>
    <% else %>
      <div>
        <p class="text-gray-800">
          <%= gettext("tags") %>
        </p>
        <ul class="flex flex-wrap gap-2">
          <%= for tag <- @photo.tags do %>
            <li class="text-sm text-gray-800 bg-gray-50 border px-2 rounded">
              <%= tag %>
            </li>
          <% end %>
        </ul>
      </div>
    <% end %>
    """
  end

  def handle_event("goto", %{"target" => "index"}, socket) do
    {:noreply, push_navigate(socket, to: home_route())}
  end

  def handle_event("activate_edit_mode", %{"field" => field} = _params, socket) do
    socket =
      assign(socket,
        editing: %{
          field: field,
          photo: socket.assigns.photo,
          changeset: Content.change_photo(socket.assigns.photo, %{})
        }
      )

    {:noreply, socket}
  end

  def handle_event("edit_mode_keydown", %{"key" => "Escape"}, socket) do
    socket = assign(socket, editing: nil)
    {:noreply, socket}
  end

  def handle_event("edit_mode_keydown", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("edit_change", %{"photo" => params} = _params, socket) do
    change_params =
      params
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms!)

    photo_changeset = Content.change_photo(socket.assigns.editing.photo, change_params)

    {:noreply,
     assign(socket, :editing, Map.put(socket.assigns.editing, :changeset, photo_changeset))}
  end

  def handle_event("edit_submit", %{"photo" => params} = _params, socket) do
    change_params =
      params
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms!)

    {:ok, photo} = Content.update_photo(socket.assigns.editing.photo, change_params)

    {:noreply,
     socket
     |> assign(:photo, photo)
     |> assign(:editing, nil)
     |> put_flash(:info, gettext("photo updated"))}
  end
end
