defmodule FotohaeckerWeb.SearchLive.Search do
  alias Fotohaecker.Search
  use FotohaeckerWeb, :live_view

  alias FotohaeckerWeb.IndexLive.Home.PhotoComponent

  @impl Phoenix.LiveView
  def mount(%{"search_query" => search_query} = _params, _session, socket) do
    grouped_search_results =
      search_query
      |> Fotohaecker.Search.search!()
      |> Fotohaecker.Search.group_by_type()

    socket =
      socket
      |> assign(
        :page_title,
        gettext("search results for %{search_query}", search_query: search_query)
      )
      |> assign(:search_query, search_query)
      |> assign(
        :grouped_search_results,
        grouped_search_results
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="search" class="space-y-1 md:space-y-2">
      <%= with result_count <- @grouped_search_results &&
                             @grouped_search_results
                             |> Enum.flat_map(fn {_key, value} -> value end)
                             |> length(),
             _has_results? <- !!result_count > 0 do %>
        <h1 class="dark:text-gray-100">Search results for "<%= @search_query %>"</h1>
        <p class="dark:text-gray-100">
          <%= ngettext(
            "1 result",
            "%{count} results",
            result_count
          ) %>
        </p>
        <%= for group <- @grouped_search_results |> Map.keys() do %>
          <.group_title group={group} />
          <%= case group do %>
            <% :photo -> %>
              <ul
                class="grid gap-4 grid-cols-2 md:grid-cols-4 lg:grid-cols-5 max-w-[1200px]"
                data-testid="result_list--photo"
              >
                <%= with photos <- Map.get(@grouped_search_results, group) do %>
                  <%= for %Search{photo: photo} <- photos do %>
                    <PhotoComponent.render photo={photo} />
                  <% end %>
                <% end %>
              </ul>
            <% :user -> %>
              <ul
                class="grid gap-4 grid-cols-1 md:grid-cols-2 lg:grid-cols-4 max-w-[1200px]"
                data-testid="result_list--user"
              >
                <%= with users <- Map.get(@grouped_search_results, group) do %>
                  <%= for %Search{user: user} <- users do %>
                    <li class="block border dark:border-gray-200 dark:hover:border-white">
                      <.link
                        href={user_route(user.id)}
                        class="link dark:link--light flex items-center gap-2 hover:shadow-md dark:hover:shadow-none"
                        id={"user-" <> user.id}
                      >
                        <img
                          class="h-16 w-16"
                          src={user.picture}
                          alt={gettext("profile picture of %{nickname}", %{nickname: user.nickname})}
                        />
                        <div class="p-2 link dark:link--light break-all"><%= user.nickname %></div>
                      </.link>
                    </li>
                  <% end %>
                <% end %>
              </ul>
          <% end %>
        <% end %>
      <% end %>
    </div>
    """
  end

  # TODO: dry
  defp group_title(%{group: :user} = assigns) do
    ~H"""
    <h2 class="font-sans dark:text-gray-100">
      <%= gettext("Users") %>
    </h2>
    """
  end

  defp group_title(%{group: :photo} = assigns) do
    ~H"""
    <h2 class="font-sans dark:text-gray-100">
      <%= gettext("Photos") %>
    </h2>
    """
  end

  defp group_title(assigns) do
    ~H"""
    <h2 class="font-sans dark:text-gray-100">
      <%= Atom.to_string(@group) %>
    </h2>
    """
  end

  # TODO: DRY: dirty
  def handle_event("navigate_to", params, socket),
    do: FotohaeckerWeb.IndexLive.Home.handle_event("navigate_to", params, socket)
end
