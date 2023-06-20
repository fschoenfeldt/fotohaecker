defmodule FotohaeckerWeb.HeaderLive.NavigationComponent.Search do
  @moduledoc false
  use FotohaeckerWeb, :component

  def search(assigns) do
    ~H"""
    <div class="w-full relative">
      <.form
        action={
          Routes.search_path(
            FotohaeckerWeb.Endpoint,
            :search,
            Gettext.get_locale(FotohaeckerWeb.Gettext)
          )
        }
        for={%{}}
        id="search_form"
        method="POST"
        class={[
          "flex w-full bg-gray-800 border border-gray-700 rounded text-white placeholder:text-gray-400",
          @search_query !== "" && "rounded-b-none"
        ]}
        phx-change="search"
        phx-target={@myself}
      >
        <label class="sr-only" for="search_query">
          <%= gettext("Search by title or tag") %>
        </label>
        <input
          class={[
            "w-full bg-transparent rounded text-white placeholder:text-gray-400 border-transparent",
            @search_query !== "" && "rounded-b-none"
          ]}
          type="text"
          value={@search_query}
          phx-debounce="500"
          placeholder="Search..."
          name="search_query"
          id="search_query"
        />
        <button :if={@search_query !== ""} type="submit" class="border-none" phx-target={@myself}>
          <Heroicons.arrow_right class="w-4 h-4 stroke-gray-200" alt="" />
          <span class="sr-only"><%= gettext("submit") %></span>
        </button>
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
      </.form>
      <div
        class={[
          "bg-gray-800 border border-gray-700 border-t-transparent rounded-b absolute top-[calc(2.5rem+4px)] z-10 w-full hidden",
          @search_results && "!block"
        ]}
        aria-live="polite"
      >
        <%= if (@search_results) && (length(@search_results) > 0) do %>
          <div class="text-gray-200 p-2">
            <%= ngettext("1 result", "%{count} results", length(@search_results)) %>
          </div>
          <ul class="flex flex-col divide-y divide-gray-700" data-testid="result_list">
            <span class="sr-only"><%= gettext("search results") %></span>
            <li
              :for={photo <- @search_results}
              class="p-2 text-gray-200 underline hover:text-gray-100 hover:bg-gray-700 cursor-pointer group"
            >
              <.link class="link link--light" href={photo_route(photo.id)}>
                <%= photo.title %>
              </.link>
            </li>
          </ul>
        <% end %>
        <%= if (@search_results) && (length(@search_results) === 0) do %>
          <div class="text-gray-200 p-2">
            <%= gettext("No results") %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
