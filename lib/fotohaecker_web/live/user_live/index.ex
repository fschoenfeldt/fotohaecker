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
      <.link
        class="btn btn--red flex items-center gap-2 max-w-max"
        href={
          Routes.page_path(
            FotohaeckerWeb.Endpoint,
            :logout,
            Gettext.get_locale(FotohaeckerWeb.Gettext)
          )
        }
      >
        <span class="text-white">
          <%= gettext("logout") %>
        </span>
      </.link>
    </div>
    """
  end
end
