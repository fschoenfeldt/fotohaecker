defmodule FotohaeckerWeb.IndexLive.Home.PhotosComponent do
  @moduledoc """
  Lists Photos on the home page.
  """
  use FotohaeckerWeb, :live_component

  alias FotohaeckerWeb.IndexLive.Home.PhotoComponent

  def render(assigns) do
    ~H"""
    <div class="photos">
      <%!-- #TODO do this via form, with single select that can be more accessible --%>
      <div class="flex justify-between">
        <div class="dark:text-gray-50">
          <%= gettext("showing %{limit} out of %{amount} photos",
            amount: @photos.amount,
            limit: @photos.user_limit
          ) %>
        </div>
        <p class="sr-only"><%= gettext("sort by") %></p>
        <ul class="sortby-options">
          <li>
            <a href="#" class="sortby-options__option sortby-options__option--active">
              <%= gettext("latest") %> <span class="sr-only"><%= gettext("(active)") %></span>
            </a>
          </li>
          <li>
            <a href="#" class="sortby-options__option">
              <%= gettext("oldest") %>
            </a>
          </li>
          <li>
            <a href="#" class="sortby-options__option">
              <%= gettext("most downloaded") %>
            </a>
          </li>
        </ul>
      </div>

      <%= if Enum.empty?(@photos) do %>
        <div class="text-center">
          <p class="text-gray-500 dark:text-gray-400 italic">
            <%= gettext("no photos, yet...") %>
          </p>
        </div>
      <% else %>
        <div
          id="photos"
          phx-update="append"
          class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 items-start gap-4"
        >
          <%= for photo <- @photos.photos do %>
            <PhotoComponent.render photo={photo} />
          <% end %>
        </div>
        <%= if @photos.amount > @photos.user_limit do %>
          <div class="flex justify-center">
            <button phx-click="show_more_photos"><%= gettext("show more") %></button>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end
end
