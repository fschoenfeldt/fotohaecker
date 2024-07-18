defmodule FotohaeckerWeb.HeaderLive.NavigationComponent.AccountSettings do
  @moduledoc false
  use FotohaeckerWeb, :component

  def account_settings(%{user_management_implemented?: false} = assigns) do
    ~H"""
    """
  end

  def account_settings(assigns) do
    ~H"""
    <%= if @current_user do %>
      <.link class="btn btn--transparent flex items-center gap-3" href={@account_link}>
        <img src={@current_user.picture} class="w-6 rounded-full" alt="" />
        <span class="sr-only sm:not-sr-only">
          <%= gettext("your account") %>
        </span>
      </.link>
    <% else %>
      <.link class="btn btn--transparent flex items-center gap-2" href={@login_link}>
        <Heroicons.arrow_left_on_rectangle mini class="h-4 w-4 dark:fill-gray-200" />
        <span class="sr-only sm:not-sr-only">
          <%= gettext("login") %>
        </span>
      </.link>
    <% end %>
    """
  end
end
