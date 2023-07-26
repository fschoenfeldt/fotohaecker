defmodule FotohaeckerWeb.UserLive.Show do
  alias FotohaeckerWeb.IndexLive.Home.PhotoComponent
  alias Fotohaecker.Auth0Management
  use FotohaeckerWeb, :live_view

  @impl Phoenix.LiveView
  def mount(%{"id" => id} = _params, _session, socket) do
    {:ok, user} = Auth0Management.user_get(id)
    user_photos = Fotohaecker.Content.list_photos_by_user(id)

    {:ok,
     socket
     |> assign(:user, user)
     |> assign(:user_photos, user_photos)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="user_show" class="">
      <div class="bg-gray-800">
        <div class="max-w-6xl mx-auto space-y-2 py-8 px-8 xl:px-0">
          <img
            src={@user["picture"]}
            alt={gettext("Profile Picture of %{nickname}", %{nickname: @user["nickname"]})}
          />
          <p class="text-gray-100"><%= @user["nickname"] %></p>
        </div>
      </div>

      <div class="max-w-6xl mx-auto space-y-2 pt-2 px-8 xl:px-0">
        <ul class="grid gap-4 grid-cols-2 md:grid-cols-4">
          <%= for photo <- @user_photos do %>
            <PhotoComponent.render photo={photo} />
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  # TODO: DRY: dirty
  def handle_event("navigate_to", params, socket),
    do: FotohaeckerWeb.IndexLive.Home.handle_event("navigate_to", params, socket)
end
