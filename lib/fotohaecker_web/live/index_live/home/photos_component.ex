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
            limit: @user_display_options.limit
          ) %>
        </div>
        <p class="sr-only"><%= gettext("sort by") %></p>
        <ul class="sortby-options">
          <li>
            <a
              phx-click="sort_by"
              phx-value-order="desc_inserted_at"
              href="#"
              class={"sortby-options__option" <> sort_active(@user_display_options.order, :desc_inserted_at)}
            >
              <%= gettext("latest") %> <span class="sr-only"><%= gettext("(active)") %></span>
            </a>
          </li>
          <li>
            <a
              phx-click="sort_by"
              phx-value-order="asc_inserted_at"
              href="#"
              class={"sortby-options__option" <> sort_active(@user_display_options.order, :asc_inserted_at)}
            >
              <%= gettext("oldest") %>
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
        <ul
          id="photos"
          class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 items-start gap-4"
        >
          <%= for photo <- @photos.photos do %>
            <PhotoComponent.render photo={photo} />
          <% end %>
        </ul>
        <%= if @photos.amount > @user_display_options.limit do %>
          <div class="flex justify-center">
            <%!-- #TODO: a11y: Focus after pressing "show more"? --%>
            <button phx-click="show_more_photos" data-testid="show_more_photos_button">
              <%= gettext("show more") %>
            </button>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def sort_active(user_order, order) do
    if user_order == order do
      " sortby-options__option--active"
    else
      ""
    end
  end
end
