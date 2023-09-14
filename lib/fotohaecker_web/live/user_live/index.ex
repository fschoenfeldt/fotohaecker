defmodule FotohaeckerWeb.UserLive.Index do
  alias Fotohaecker.Auth0Management
  use FotohaeckerWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, user} = Auth0Management.user_get(socket.assigns.current_user.id)
    current_user = Map.merge(socket.assigns.current_user, user)
    {:ok, assign(socket, :current_user, current_user)}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="user" class="max-w-6xl mx-auto space-y-2 pt-2">
      <h1 class="dark:text-gray-100"><%= gettext("Your Account") %></h1>
      <dl class="space-y-2">
        <%!-- # TODO: DRY --%>
        <dt class="font-bold dark:text-gray-100"><%= gettext("Name/Email") %></dt>
        <dd class="dark:text-gray-100"><%= @current_user.name %></dd>
        <dt class="font-bold dark:text-gray-100"><%= gettext("Nickname") %></dt>
        <dd class="dark:text-gray-100"><%= @current_user["nickname"] %></dd>
        <dt class="font-bold dark:text-gray-100"><%= gettext("Your Profile Link") %></dt>
        <dd class="dark:text-gray-100">
          <a href={user_route(@current_user.id)}>
            <%= user_url(@current_user.id) %>
          </a>
        </dd>
      </dl>
      <.form
        for={%{}}
        method="post"
        action={
          FotohaeckerWeb.Router.Helpers.auth_path(
            @socket,
            :delete_account,
            Gettext.get_locale(FotohaeckerWeb.Gettext)
          )
        }
      >
        <button type="submit" class="btn">
          <%= gettext("Delete Account") %>
        </button>
      </.form>

      <.form
        for={%{}}
        method="post"
        action={
          FotohaeckerWeb.Router.Helpers.auth_path(
            @socket,
            :logout
          )
        }
      >
        <button
          type="submit"
          class="btn btn--red flex items-center gap-2 max-w-max"
          href={
            # TODO this doesn't work!
            Routes.auth_path(
              FotohaeckerWeb.Endpoint,
              :logout
            )
          }
        >
          <%= gettext("logout") %>
        </button>
      </.form>
    </div>
    """
  end
end
