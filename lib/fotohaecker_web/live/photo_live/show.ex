defmodule FotohaeckerWeb.PhotoLive.Show do
  alias Fotohaecker.UserManagement
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
    case Content.get_photo(id, [:recipe]) do
      %Content.Photo{} = photo ->
        {:noreply,
         socket
         |> assign(:page_title, photo.title)
         |> assign(:photo, photo)
         # TODO: is this good?
         |> assign(:show_delete_photo_confirmation_modal, false)}

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
               recipe       <- @photo.recipe,
               # TODO DRY: don't hardcode paths here…
               path         <- Routes.static_path(FotohaeckerWeb.Endpoint,
                                                  "/uploads/#{file_name}_og#{extension}"),
               preview_path <- Routes.static_path(FotohaeckerWeb.Endpoint,
                                                  "/uploads/#{file_name}_preview#{extension}") do %>
        <div class="grid md:gap-8 md:grid-cols-12">
          <.download_link class="col-span-8 bg-[#17181b] md:py-8" href={path} photo={@photo}>
            <img
              class="w-auto max-h-[calc(100vh-10rem)] mx-auto"
              src={preview_path}
              alt={gettext("photo %{title} on Fotohäcker", %{title: title})}
            />
          </.download_link>
          <div class="col-span-4 m-4 md:pt-4 space-y-4">
            <.back_button />
            <.title
              photo={@photo}
              editing={@editing}
              is_photo_owner?={Content.is_photo_owner?(@photo, @current_user)}
            />
            <.upload_date_and_user photo={@photo} />
            <.tags
              photo={@photo}
              editing={@editing}
              is_photo_owner?={Content.is_photo_owner?(@photo, @current_user)}
            />
            <%= if Fotohaecker.RecipeManagement.is_implemented?() do %>
              <.recipe_card recipe={recipe} />
            <% end %>
            <div class="flex space-x-4">
              <.download_link class="btn btn--green flex gap-2 w-max" href={path} photo={@photo}>
                <Heroicons.arrow_down_tray class="w-6 h-6 stroke-white" /> <%= gettext("Download") %>
              </.download_link>
              <button
                :if={Content.is_photo_owner?(@photo, @current_user)}
                class="btn btn--red flex gap-2 w-max"
                phx-click="show_delete_photo_confirmation_modal"
              >
                <Heroicons.trash class="w-6 h-6 stroke-white" /> <%= gettext("Delete") %>
              </button>
            </div>
            <%= if @show_delete_photo_confirmation_modal do %>
              <.delete_photo_confirmation_modal photo={@photo} />
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # TODO: when no javascript is available, show a link to delete the photo
  #       -> https://github.com/fschoenfeldt/fotohaecker/issues/117
  attr(:photo, Photo)

  defp delete_photo_confirmation_modal(assigns) do
    ~H"""
    <.modal
      title={gettext("Delete photo")}
      return_to={FotohaeckerWeb.LiveHelpers.photo_route(@photo.id)}
    >
      <%= gettext("Are you sure you want to delete this photo?") %>
      <div class="flex gap-2">
        <button
          data-testid="confirm-delete-button"
          class="btn btn--red flex gap-2 w-max"
          phx-click="delete_photo"
        >
          <Heroicons.trash class="w-6 h-6 stroke-white" /> <%= gettext("Delete") %>
        </button>
        <button
          data-testid="cancel-delete-button"
          class="btn btn--dark flex gap-2 w-max"
          phx-click={JS.dispatch("click", to: "#close")}
        >
          <Heroicons.x_circle class="w-6 h-6 stroke-black" /> <%= gettext("Cancel") %>
        </button>
      </div>
    </.modal>
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
      data-testid="back-button"
      phx-click="goto"
      phx-keydown="goto"
      phx-key="Enter"
      phx-value-target="index"
      class="w-max px-2 -mx-2 flex gap-1 items-center text-gray-800 dark:text-gray-100 fill-black"
    >
      <Heroicons.arrow_left mini class="w-4 h-4 fill-gray-800 dark:fill-gray-100" />
      <%= gettext("back") %>
    </.link>
    """
  end

  attr(:photo, Photo, required: true)

  defp upload_date_and_user(assigns) do
    ~H"""
    <p class="text-sm">
      <span
        x-data
        x-text={alpine_format_date(@photo.inserted_at)}
        class="text-gray-800 dark:text-gray-100"
      >
        <%= gettext("uploaded on %{date}", %{date: @photo.inserted_at}) %>
      </span>
      <span class="text-gray-700 dark:text-gray-300 italic">
        <%= if @photo.user_id !== nil do %>
          <%= case UserManagement.get(@photo.user_id) do %>
            <% {:ok, user} -> %>
              <a href={user_route(@photo.user_id)}>
                <%= gettext("by %{user}", %{user: user.nickname}) %>
              </a>
            <% _ -> %>
              <%= if UserManagement.is_implemented?() do %>
                <a href={user_route(@photo.user_id)}>
                  <%= gettext("by user_id %{user_id}", %{user_id: @photo.user_id}) %>
                </a>
              <% else %>
                <%= gettext("by user %{user_id}", %{user_id: @photo.user_id}) %>
              <% end %>
          <% end %>
        <% else %>
          <%= gettext("by an anonymous user") %>
        <% end %>
      </span>
    </p>
    """
  end

  attr(:photo, Photo, required: true)
  attr(:editing, :any, required: true)
  attr(:is_photo_owner?, :boolean, required: true)

  defp title(%{editing: %{field: "title", changeset: _changeset} = _editing} = assigns) do
    ~H"""
    <.form_for editing={@editing} />
    """
  end

  defp title(%{editing: _} = assigns) do
    ~H"""
    <div class="flex items-end gap-x-1">
      <h1 data-testid="title" class="text-gray-800 dark:text-gray-100">
        <%= @photo.title %>
      </h1>
      <.edit_button :if={@is_photo_owner?} field="title" />
    </div>
    """
  end

  attr(:photo, Photo, required: true)
  attr(:editing, :any, required: true)
  attr(:is_photo_owner?, :boolean, required: true)

  defp tags(%{editing: %{field: "tags", changeset: _changeset} = _editing} = assigns) do
    ~H"""
    <.form_for editing={@editing} input_class="w-full text-sm" />
    """
  end

  defp tags(%{editing: _} = assigns) do
    ~H"""
    <div class="flex items-end gap-x-1">
      <%= if length(@photo.tags) == 0 do %>
        <p data-testid="tags" class="text-sm text-gray-800 dark:text-gray-100">
          <%= gettext("no tags") %>
        </p>
      <% else %>
        <div>
          <p class="text-gray-800 dark:text-gray-100">
            <%= gettext("tags") %>
          </p>
          <ul data-testid="tags" class="flex flex-wrap gap-2">
            <%= for tag <- @photo.tags do %>
              <li class="text-sm text-gray-800 dark:text-gray-100 bg-gray-100 dark:bg-gray-800 border dark:border-gray-600 px-2 rounded">
                <%= tag %>
              </li>
            <% end %>
          </ul>
        </div>
      <% end %>
      <.edit_button :if={@is_photo_owner?} field="tags" />
    </div>
    """
  end

  defp recipe_card(%{recipe: nil} = assigns) do
    ~H"""

    """
  end

  defp recipe_card(assigns) do
    ~H"""
    <p class="text-xs text-gray-600">Recipe used:</p>
    <div class="rounded bg-gradient-to-br from-yellow-300 to-red-800 shadow-sm border-gray-400 relative !mt-1">
      <div class="grain-effect"></div>
      <div class="p-2 overflow-hidden relative">
        <%!-- # FIXME: dont use absolute bs --%>
        <div aria-hidden="true" class="bg-yellow-200 rounded-full w-12 h-12 p-4 absolute top-1/8">
          <Heroicons.film class="w-1/2 h-1/2 top-1/4 left-1/4 stroke-red-800 absolute transform rotate-45 z-0" />
        </div>

        <div class="ms-14 p-2 rounded-md z-0 relative bg-yellow-300/75 backdrop-blur-md w-max">
          <%= case @recipe.brand do %>
            <% "fujifilm" -> %>
              <%!-- # FIXME: use own logo --%>
              <img
                src="https://upload.wikimedia.org/wikipedia/commons/a/a1/Fujifilm_logo.svg"
                alt="Fujifilm"
                class="h-2 mb-1"
              />
          <% end %>
          <.link href={recipe_route(@recipe.id)} class="text-md text-gray-800 dark:text-gray-100">
            <%= @recipe.title %>
          </.link>
        </div>
      </div>
    </div>
    <%!-- <%= inspect(@recipe) %> --%>
    """
  end

  attr(:editing, :any, required: true)
  attr(:input_class, :string, default: "text-2xl")

  defp form_for(assigns) do
    ~H"""
    <.form
      :let={f}
      for={@editing.changeset}
      class="border-2 border-dashed p-2 -mx-2 md:max-w-max"
      phx-change="edit_change"
      phx-submit="edit_submit"
    >
      <label class="block text-gray-800 dark:text-gray-100" for={"photo_#{@editing.field}"}>
        <%= gettext("enter new %{field}", %{field: @editing.field}) %>
      </label>
      <div class="flex flex-wrap items-center gap-2">
        <%!-- # TODO: focus field after activating edit mode --%>
        <input
          id={"photo_#{@editing.field}"}
          class={["p-2 bg-gray-100 max-w-full", @input_class]}
          name={"photo[#{@editing.field}]"}
          value={field_value(@editing)}
          placeholder={gettext("photo %{field}", %{field: @editing.field})}
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
            <Heroicons.check
              mini
              class="w-4 h-4 fill-gray-800 dark:!fill-gray-200 group-hover:fill-white dark:group-hover:fill-gray-500"
              alt=""
            />
            <div class="text-gray-800 dark:text-gray-200 group-hover:text-white">
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
            <Heroicons.no_symbol
              mini
              class="w-4 h-4 fill-gray-800 dark:!fill-gray-200 group-hover:fill-white dark:group-hover:fill-gray-500"
              alt=""
            />
            <div class="text-gray-800 dark:text-gray-200 group-hover:text-white">
              <%= gettext("cancel") %>
            </div>
          </button>
        </div>
      </div>
      <%= error_tag(f, String.to_existing_atom(@editing.field)) %>
    </.form>
    """
  end

  defp field_value(editing),
    do:
      editing.photo
      |> Map.get(String.to_existing_atom(editing.field))
      |> maybe_convert()

  defp maybe_convert(field) when is_list(field), do: Content.from_tags(field)
  defp maybe_convert(field), do: field

  attr(:field, :string, required: true)

  defp edit_button(assigns) do
    ~H"""
    <button
      data-testid={"edit-button-#{@field}"}
      type="button"
      class="group btn btn--dark p-1 border-none"
      id={"activate_photo_#{@field}"}
      phx-hook="EditPhotoField"
      data-field={@field}
    >
      <Heroicons.pencil_square mini class="w-4 h-4 dark:fill-gray-200 group-hover:fill-white" />
      <div class="sr-only">
        <%= gettext("edit field %{field}", %{field: @field}) %>
      </div>
    </button>
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
      |> Map.update(:tags, nil, fn tags -> Content.to_tags(tags) end)

    photo_changeset = Content.change_photo(socket.assigns.editing.photo, change_params)

    {:noreply,
     assign(socket, :editing, Map.put(socket.assigns.editing, :changeset, photo_changeset))}
  end

  def handle_event("edit_submit", %{"photo" => params} = _params, socket) do
    change_params =
      params
      |> Jason.encode!()
      |> Jason.decode!(keys: :atoms!)

    changes =
      if change_params[:tags] !== nil do
        Map.update(change_params, :tags, [], fn tags -> Content.to_tags(tags) end)
      else
        change_params
      end

    {:ok, photo} = Content.update_photo(socket.assigns.editing.photo, changes)

    {:noreply,
     socket
     |> assign(:photo, photo)
     |> assign(:editing, nil)
     |> put_flash(:info, gettext("photo updated"))}
  end

  def handle_event("show_delete_photo_confirmation_modal", _params, socket) do
    {:noreply, assign(socket, :show_delete_photo_confirmation_modal, true)}
  end

  def handle_event("delete_photo", _params, socket) do
    photo = socket.assigns.photo

    case Content.delete_photo(photo, socket.assigns.current_user) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("photo deleted"))
         |> push_navigate(to: home_route())}

      {:error, message} ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  # TODO: DRY: dirty
  def handle_event("navigate_to", params, socket),
    do: FotohaeckerWeb.IndexLive.Home.handle_event("navigate_to", params, socket)
end
