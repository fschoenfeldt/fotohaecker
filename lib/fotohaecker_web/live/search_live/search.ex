defmodule FotohaeckerWeb.SearchLive.Search do
  use FotohaeckerWeb, :live_view

  alias Fotohaecker.Content
  alias FotohaeckerWeb.IndexLive.Home.PhotoComponent

  @impl Phoenix.LiveView
  def mount(%{"search_query" => search_query} = _params, _session, socket) do
    socket =
      socket
      |> assign(
        :page_title,
        gettext("search results for %{search_query}", search_query: search_query)
      )
      |> assign(:search_query, search_query)
      |> assign(:search_results, Content.search_photos(search_query))

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div id="search">
      <h1 class="dark:text-gray-100">Search results for "<%= @search_query %>"</h1>
      <p class="dark:text-gray-100">
        <%= gettext("%{amount} results", %{amount: length(@search_results)}) %>
      </p>
      <ul class="grid grid-cols-6">
        <%= for photo <- @search_results do %>
          <PhotoComponent.render photo={photo} />
        <% end %>
        <div :if={length(@search_results) === 0} class="col-span-full">
          <p><%= gettext("No results found") %></p>
        </div>
      </ul>
    </div>
    """
  end

  # TODO: DRY: dirty
  def handle_event("navigate_to", params, socket),
    do: FotohaeckerWeb.IndexLive.Home.handle_event("navigate_to", params, socket)
end
