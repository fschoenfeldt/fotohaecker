defmodule FotohaeckerWeb.HeaderLive.NavigationComponent.SearchComponent do
  @moduledoc false
  alias Fotohaecker.Search
  use FotohaeckerWeb, :component

  attr :search_query, :string
  attr :grouped_search_results, :list
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
        <.search_results grouped_search_results={@grouped_search_results} />
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
      required
    />
    """
  end

  attr :grouped_search_results, :map

  defp search_results(assigns) do
    ~H"""
    <%= with result_count <- @grouped_search_results &&
                             @grouped_search_results
                             |> Enum.flat_map(fn {_key, value} -> value end)
                             |> length(),
             has_results? <- !!result_count do %>
      <div
        class={[
          "bg-gray-800 border border-gray-700 border-t-transparent rounded-b absolute top-[calc(2.5rem+4px)] z-10 w-full hidden",
          has_results? && "!block"
        ]}
        aria-live="polite"
      >
        <.search_result_list
          grouped_search_results={@grouped_search_results}
          has_results?={has_results?}
          result_count={result_count}
        />
      </div>
    <% end %>
    """
  end

  attr :grouped_search_results, :map
  attr :has_results?, :boolean
  attr :result_count, :integer

  defp search_result_list(%{grouped_search_results: nil} = assigns) do
    ~H"""

    """
  end

  defp search_result_list(%{has_results?: false} = assigns) do
    ~H"""
    <div class="text-gray-200 p-2">
      <%= gettext("No results") %>
    </div>
    """
  end

  defp search_result_list(%{grouped_search_results: _grouped_search_results} = assigns) do
    ~H"""
    <div class="text-gray-200 p-2">
      <%= ngettext(
        "1 result",
        "%{count} results",
        @result_count
      ) %>
    </div>
    <span class="sr-only"><%= gettext("search results") %></span>
    <%= for group <- @grouped_search_results |> Map.keys() do %>
      <.group_title group={group} />
      <ul
        class="flex flex-col divide-y divide-gray-700 list-inside list-disc"
        data-testid={"result_list--#{Atom.to_string(group)}"}
      >
        <li
          :for={%Search{} = search_result <- Map.get(@grouped_search_results, group)}
          class="hover:bg-gray-700 text-white pl-2"
        >
          <.search_result_item item={search_result} />
        </li>
      </ul>
    <% end %>
    """
  end

  attr :item, Search

  defp search_result_item(%{item: %Search{type: :photo, photo: _photo}} = assigns) do
    ~H"""
    <.search_result_item_link href={photo_route(@item.photo.id)} title={@item.photo.title} />
    """
  end

  defp search_result_item(%{item: %Search{type: :user, user: _user}} = assigns) do
    ~H"""
    <.search_result_item_link href={user_route(@item.user.id)} title={@item.user.nickname} />
    """
  end

  defp search_result_item_link(assigns) do
    ~H"""
    <.link class="py-2 inline-block w-[calc(100%-2rem)] h-full link link--light" href={@href}>
      <%= @title %>
    </.link>
    """
  end

  defp group_title(%{group: :user} = assigns) do
    ~H"""
    <div class="text-gray-200 p-2">
      <%= gettext("Users") %>
    </div>
    """
  end

  defp group_title(%{group: :photo} = assigns) do
    ~H"""
    <div class="text-gray-200 p-2">
      <%= gettext("Photos") %>
    </div>
    """
  end

  defp group_title(assigns) do
    ~H"""
    <div class="text-gray-200 p-2">
      <%= Atom.to_string(@group) %>
    </div>
    """
  end
end
