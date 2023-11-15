defmodule FotohaeckerWeb.HeaderLive.NavigationComponent.SearchComponent do
  @moduledoc false
  alias Fotohaecker.Search
  use FotohaeckerWeb, :component

  attr :search_query, :string
  attr :search_results, :list
  attr :myself, :any

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
        <.search_input search_query={@search_query} />
        <.search_submit_or_cancel myself={@myself} search_query={@search_query} />
        <.search_results search_results={@search_results} />
      </.form>
    </div>
    """
  end

  defp search_submit_or_cancel(assigns) do
    ~H"""
    <button
      :if={@search_query !== ""}
      type="submit"
      class="btn btn--dark hover:bg-gray-700 border-none"
      phx-target={@myself}
    >
      <Heroicons.arrow_right class="w-4 h-4 stroke-gray-200" alt="" />
      <span class="sr-only"><%= gettext("submit") %></span>
    </button>
    <button
      :if={@search_query !== ""}
      type="button"
      class="btn btn--dark hover:bg-gray-700 border-none"
      phx-click="search_reset"
      phx-target={@myself}
    >
      <Heroicons.x_mark class="w-4 h-4 stroke-gray-200" alt="" />
      <span class="sr-only"><%= gettext("clear search") %></span>
    </button>
    """
  end

  defp search_input(assigns) do
    ~H"""
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
      placeholder={gettext("Search…")}
      name="search_query"
      id="search_query"
    />
    """
  end

  attr :search_results, :list

  defp search_results(assigns) do
    ~H"""
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
        <%!-- # TODO: refactor this and use photos_component.ex  --%>
        <ul class="flex flex-col divide-y divide-gray-700" data-testid="result_list">
          <span class="sr-only"><%= gettext("search results") %></span>
          <li :for={search_result <- @search_results} class="hover:bg-gray-700">
            <.search_result_item item={search_result} />
          </li>
        </ul>
      <% end %>
      <%= if (@search_results) && (length(@search_results) === 0) do %>
        <div class="text-gray-200 p-2">
          <%= gettext("No results") %>
        </div>
      <% end %>
    </div>
    """
  end

  defp search_result_item(%{item: %Search{type: :photo, photo: _photo}} = assigns) do
    ~H"""
    <.link class="p-2 block h-full w-full link link--light" href={photo_route(@item.photo.id)}>
      <%= @item.photo.title %>
    </.link>
    """
  end

  defp search_result_item(%{item: %Search{type: :user, user: _user}} = assigns) do
    ~H"""
    <.link class="p-2 block h-full w-full link link--light" href={user_route(@item.user.id)}>
      <%= @item.user.nickname %>
    </.link>
    """
  end
end
