defmodule FotohaeckerWeb.HeaderLive.NavigationComponent.SearchComponent do
  @moduledoc false
  alias Fotohaecker.Search
  use FotohaeckerWeb, :component

  attr :search_query, :string
  attr :grouped_search_results, :list
  attr :result_count, :integer
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
          "flex w-full bg-gray-100 border border-gray-300 rounded text-gray-800 placeholder:text-gray-400",
          @search_query !== "" && "rounded-b-none"
        ]}
        phx-change="search"
        phx-target={@myself}
      >
        <.search_input search_query={@search_query} />
        <.search_submit_or_cancel myself={@myself} search_query={@search_query} />
        <.search_results
          grouped_search_results={@grouped_search_results}
          result_count={@result_count}
        />
      </.form>
    </div>
    """
  end

  defp search_submit_or_cancel(assigns) do
    ~H"""
    <button
      :if={@search_query !== ""}
      type="submit"
      class="btn btn--transparent hover:bg-gray-200 border-none"
      phx-target={@myself}
    >
      <Heroicons.arrow_right class="w-4 h-4 stroke-gray-800" alt="" />
      <span class="sr-only"><%= gettext("submit") %></span>
    </button>
    <button
      :if={@search_query !== ""}
      type="button"
      class="btn btn--transparent hover:bg-gray-200 border-none"
      phx-click="search_reset"
      phx-target={@myself}
    >
      <Heroicons.x_mark class="w-4 h-4 stroke-gray-800" alt="" />
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
        "w-full bg-transparent rounded text-gray-800 placeholder:text-gray-400 border-transparent",
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
  attr :result_count, :integer

  defp search_results(assigns) do
    ~H"""
    <div
      class={[
        "bg-gray-100 border border-gray-500 border-t-transparent
        rounded-b absolute top-[calc(2.5rem+4px)] z-10 w-full max-h-[calc(100vh-4rem)] overflow-y-auto hidden",
        !!@grouped_search_results && "!block"
      ]}
      aria-live="polite"
    >
      <.search_result_list
        grouped_search_results={@grouped_search_results}
        result_count={@result_count}
      />
    </div>
    """
  end

  attr :grouped_search_results, :map
  attr :result_count, :integer

  defp search_result_list(%{grouped_search_results: nil} = assigns) do
    ~H"""
    """
  end

  defp search_result_list(%{result_count: 0} = assigns) do
    ~H"""
    <div class="text-gray-800 p-2">
      <%= gettext("No results") %>
    </div>
    """
  end

  defp search_result_list(%{grouped_search_results: _grouped_search_results} = assigns) do
    ~H"""
    <div class="text-gray-800 p-2">
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
        class="flex flex-col divide-y divide-gray-300"
        data-testid={"result_preview_list--#{Atom.to_string(group)}"}
      >
        <li
          :for={%Search{} = search_result <- Map.get(@grouped_search_results, group)}
          class="flex items-center hover:bg-gray-200 text-gray-800 pl-2 before:content-['-'] before:block before:mr-2 before:text-gray-400]"
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
    <.link class="py-2 block w-full h-full link text-ellipsis overflow-hidden" href={@href}>
      <%= @title %>
    </.link>
    """
  end

  defp group_title(%{group: :user} = assigns) do
    ~H"""
    <div class="text-gray-800 font-bold p-2">
      <%= gettext("Users") %>
    </div>
    """
  end

  defp group_title(%{group: :photo} = assigns) do
    ~H"""
    <div class="text-gray-800 font-bold p-2">
      <%= gettext("Photos") %>
    </div>
    """
  end

  defp group_title(assigns) do
    ~H"""
    <div class="text-gray-800 p-2">
      <%= Atom.to_string(@group) %>
    </div>
    """
  end
end
