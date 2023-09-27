defmodule FotohaeckerWeb.UserLive.Index do
  alias Fotohaecker.UserManagement
  use FotohaeckerWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    current_user = UserManagement.get(socket.assigns.current_user.id)

    socket =
      case current_user do
        {:ok, user} ->
          assign(socket, :current_user, user)

        error ->
          assign(socket, :error, error)
      end

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="user" class="max-w-6xl mx-auto space-y-2 pt-2">
      <h1 class="dark:text-gray-100"><%= gettext("Your Account") %></h1>

      <.account_info error={Map.get(assigns, :error)} current_user={Map.get(assigns, :current_user)} />
      <.delete_logout socket={@socket} current_user={Map.get(assigns, :current_user)} />
    </div>
    """
  end

  defp delete_logout(assigns) do
    ~H"""
      <div class="flex space-x-4">
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
          <button type="submit" class="btn">
            <%= gettext("logout") %>
          </button>
        </.form>

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
          <button type="submit" class="btn btn--red">
            <%= gettext("Delete Account") %>
          </button>
        </.form>
      </div>
    """
  end

  attr(:current_user, :any)
  attr(:error, :any)

  defp account_info(%{error: error} = assigns) when is_tuple(error) do
    ~H"""
    <p class="font-bold dark:text-gray-100">
      There was an error fetching your user information: <%= @error["statusCode"] %>: <%= @error[
        "message"
      ] %>
    </p>
    """
  end

  defp account_info(assigns) do
    ~H"""
    <dl class="space-y-2">
      <dt class="font-bold dark:text-gray-100"><%= gettext("Name/Email") %></dt>
      <dd class="dark:text-gray-100"><%= @current_user.email %></dd>
      <dt class="font-bold dark:text-gray-100"><%= gettext("Nickname") %></dt>
      <dd class="dark:text-gray-100"><%= @current_user.nickname %></dd>
      <dt class="font-bold dark:text-gray-100"><%= gettext("Your Profile Link") %></dt>
      <dd class="dark:text-gray-100">
        <a href={user_route(@current_user.id)}>
          <%= user_url(@current_user.id) %>
        </a>
      </dd>
    </dl>
    """
  end
end
