defmodule FotohaeckerWeb.HeaderLive.NavigationComponent.LanguageSelect do
  @moduledoc false
  use FotohaeckerWeb, :component

  def language_select(assigns) do
    ~H"""
    <div x-data="{expanded: false}">
      <button
        data-testid="change-locale-button"
        class="btn btn--transparent flex items-center gap-2"
        type="button"
        @click="expanded = !expanded"
      >
        <Heroicons.language mini class="h-4 w-4 !fill-gray-800" />
        <span class="sr-only sm:not-sr-only text-gray-800">
          <%= gettext("change language") %>
        </span>
      </button>
      <ul
        data-testid="change-locale-menu"
        x-cloak
        x-show="expanded"
        @click.away="expanded = false"
        class="bg-gray-50 dark:bg-gray-800 p-2 rounded mt-2 absolute z-10 space-y-2 items-start"
      >
        <%= for locale <- Gettext.known_locales(FotohaeckerWeb.Gettext) do %>
          <li>
            <%= with {name, url} <- locale_gui(locale) do %>
              <a
                phx-click="change_locale"
                phx-value-to={locale}
                phx-keydown="change_locale"
                phx-key="Enter"
                tabindex="0"
                @click="expanded = false"
                @keydown.enter="expanded = false"
                class="flex text-gray-700 dark:text-gray-800 gap-2"
              >
                <img src={url} class="w-10" alt="" />
                <%= name %>
              </a>
            <% end %>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
