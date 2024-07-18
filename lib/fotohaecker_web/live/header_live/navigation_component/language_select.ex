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
        <Heroicons.language mini class="h-4 w-4 dark:fill-gray-200" />
        <span class="sr-only sm:not-sr-only">
          <%= gettext("change language") %>
        </span>
      </button>
      <ul
        data-testid="change-locale-menu"
        x-cloak
        x-show="expanded"
        @click.away="expanded = false"
        class="bg-gray-50 dark:bg-gray-800 p-3 rounded mt-2 absolute z-10 space-y-3 items-start shadow border"
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
                class="flex text-gray-700 dark:text-gray-200 gap-2"
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
