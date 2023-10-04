defmodule FotohaeckerWeb.UserLive.Show do
  alias FotohaeckerWeb.IndexLive.Home.PhotoComponent
  alias Fotohaecker.UserManagement
  use FotohaeckerWeb, :live_view

  @impl Phoenix.LiveView
  def mount(%{"id" => id} = _params, _session, socket) do
    maybe_user = UserManagement.get(id)

    socket =
      case maybe_user do
        {:ok, user} ->
          user_photos = Fotohaecker.Content.list_photos_by_user(id)

          socket
          |> assign(:user, user)
          |> assign(:user_photos, user_photos)

        {:error, reason} ->
          # in case of 404, we should rather redirect to 404 page instead of printing error
          assign(socket, :error, reason)
      end

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="user_show" class="">
      <div class="bg-gray-800">
        <div class="max-w-6xl mx-auto space-y-2 py-8 px-8 xl:px-0">
          <%= if !!assigns[:user] do %>
            <img
              data-testid="profile-picture"
              src={@user.picture}
              alt={gettext("Profile Picture of %{nickname}", %{nickname: @user.nickname})}
            />
            <h1 class="text-gray-100 font-sans break-words"><%= @user.nickname %></h1>
          <% end %>
          <%= if !!assigns[:error] do %>
            <h1 class="text-gray-100 font-sans break-words">
              <%= @error["statusCode"] %>: <%= @error["message"] %>
            </h1>
          <% end %>
        </div>
      </div>

      <%= if !!assigns[:user] and !!assigns[:user_photos] do %>
        <div class="max-w-6xl mx-auto space-y-2 pt-2 px-8 xl:px-0">
          <ul data-testid="photo_list" class="grid gap-4 grid-cols-2 md:grid-cols-4">
            <%= for photo <- @user_photos do %>
              <PhotoComponent.render photo={photo} />
            <% end %>
          </ul>
        </div>
      <% end %>
    </div>
    """
  end

  # TODO: DRY: dirty
  def handle_event("navigate_to", params, socket),
    do: FotohaeckerWeb.IndexLive.Home.handle_event("navigate_to", params, socket)
end
