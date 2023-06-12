defmodule FotohaeckerWeb.HeaderLive.NavigationComponent.Search do
  @moduledoc false
  use FotohaeckerWeb, :component

  def search(assigns) do
    ~H"""
    <div class="w-full">
      <form method="POST" class="w-full">
        <label class="sr-only" for="search">
          <%= gettext("Search") %>
        </label>
        <input
          class="w-full bg-gray-800 border-gray-700 rounded text-white placeholder:text-gray-400"
          type="text"
          value={@search}
          phx-debounce="200"
          phx-keyup="search"
          placeholder="Search..."
          name="search"
          id="search"
          phx-target={@myself}
        />
      </form>
    </div>
    """
  end
end
