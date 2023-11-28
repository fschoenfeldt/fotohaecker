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
    <%!-- # TODO: refactor me without double bools --%>
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
        <.donation_banner user={@user} />
        <div class="max-w-6xl mx-auto space-y-2 py-2 px-8 xl:px-0">
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

  defp donation_banner(assigns) do
    ~H"""
    <%= if Fotohaecker.Payment.is_fully_onboarded?(@user) do %>
      <div class="bg-green-100 py-2" data-testid="donationBanner">
        <div class="flex gap-4 flex-wrap items-center justify-between max-w-6xl mx-2 md:mx-auto">
          <p><%= gettext("Donate to %{user} to support their work", user: @user.nickname) %></p>
          <button type="button" class="btn btn--green inline-block" phx-click="donate">
            <%= gettext("donate") %>
          </button>
        </div>
      </div>
    <% end %>
    """
  end

  # TODO: DRY: dirty
  def handle_event("navigate_to", params, socket),
    do: FotohaeckerWeb.IndexLive.Home.handle_event("navigate_to", params, socket)

  def handle_event("donate", _params, socket) do
    maybe_donation_link =
      Fotohaecker.Payment.checkout(socket.assigns.user)

    case maybe_donation_link do
      {:ok, %{url: url}} ->
        {:noreply, redirect(socket, external: url)}

      {:error, %{message: message}} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           gettext("error initializing donation: %{message}", message: message)
         )}
    end
  end
end
