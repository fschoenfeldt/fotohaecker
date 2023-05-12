defmodule FotohaeckerWeb.UserLive.Index do
  use FotohaeckerWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="user" class="max-w-6xl mx-auto space-y-2 pt-2">
      <h1><%= gettext("Your Account") %></h1>
      <dl class="space-y-2">
        <dt class="font-bold"><%= gettext("Name/Email") %></dt>
        <dd><%= @current_user.name %></dd>
      </dl>
      <button type="button" class="btn" disabled>
        <%= gettext("Delete Account (coming soon!)") %>
      </button>
      <.link
        class="btn btn--red flex items-center gap-2 max-w-max"
        href={Routes.auth_path(FotohaeckerWeb.Endpoint, :delete)}
      >
        <span class="text-white">
          <%= gettext("logout") %>
        </span>
      </.link>
    </div>
    """
  end
end
