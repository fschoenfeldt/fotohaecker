defmodule FotohaeckerWeb.HeaderLive.NavigationComponent.Search do
  @moduledoc false
  use FotohaeckerWeb, :component

  def search(assigns) do
    ~H"""
    <div class="w-full relative">
      <form
        id="search_form"
        method="POST"
        class="flex w-full bg-gray-800 border border-gray-700 rounded text-white placeholder:text-gray-400"
        phx-change="search"
        phx-target={@myself}
      >
        <label class="sr-only" for="search_query">
          <%= gettext("Search by title or tag") %>
        </label>
        <input
          class={[
            "w-full bg-transparent rounded text-white placeholder:text-gray-400 border-transparent",
            @search_results && length(@search_results) && "rounded-b-none"
          ]}
          type="text"
          value={@search_query}
          phx-debounce="500"
          placeholder="Search..."
          name="search_query"
          id="search_query"
        />
        <button
          :if={@search_query !== ""}
          type="button"
          class="border-none"
          phx-click="search_reset"
          phx-target={@myself}
        >
          <Heroicons.x_mark class="w-4 h-4 stroke-gray-200" alt="" />
          <span class="sr-only"><%= gettext("clear search") %></span>
        </button>
      </form>
      <ul
        class="bg-gray-800 border border-gray-700 border-t-transparent rounded-b absolute top-[calc(2.5rem+2px)] z-10 w-full flex flex-col divide-y divide-gray-700"
        aria-live="polite"
      >
        <%= if (@search_results) && (length(@search_results) > 0) do %>
          <span class="sr-only"><%= gettext("search results") %></span>
          <li
            :for={photo <- @search_results}
            class="p-2 text-gray-200"
            tabindex="0"
            aria-role="link"
            phx-click="navigate_to"
            phx-keydown="navigate_to"
            phx-key="Enter"
            phx-value-photo_id={photo.id}
          >
            <%= photo.title %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
