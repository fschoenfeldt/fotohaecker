defmodule FotohaeckerWeb.HeaderLive.NavigationComponent do
  @moduledoc false
  use FotohaeckerWeb, :live_component

  import __MODULE__.AccountSettings
  import __MODULE__.LanguageSelect
  import __MODULE__.SearchComponent

  def mount(socket) do
    {:ok,
     socket
     |> assign(:search_query, "")
     |> assign(:grouped_search_results, nil)
     |> assign(:result_count, 0)
     |> assign(
       :account_link,
       Routes.user_index_path(
         socket,
         :index,
         Gettext.get_locale(FotohaeckerWeb.Gettext)
       )
     )
     |> assign(
       :login_link,
       Routes.auth_path(
         socket,
         :login,
         %{
           "provider" => "auth0",
           "locale" => Gettext.get_locale(FotohaeckerWeb.Gettext)
         }
       )
     )}
  end

  def render(assigns) do
    ~H"""
    <nav class="w-full">
      <ul class="flex items-center justify-center gap-1 sm:gap-2">
        <%= with maximize_search_bar? <- @search_query !== "" do %>
          <li class={[maximize_search_bar? && "sr-only md:not-sr-only"]}>
            <a
              href={
                Routes.index_home_path(@socket, :home, Gettext.get_locale(FotohaeckerWeb.Gettext))
              }
              class="text-gray-800 text-xl px-2 font-bold"
            >
              Fotohäcker
            </a>
          </li>
          <li class="flex-1">
            <.search
              search_query={@search_query}
              grouped_search_results={@grouped_search_results}
              result_count={@result_count}
              myself={@myself}
            />
          </li>
          <li class={[maximize_search_bar? && "sr-only md:not-sr-only"]}>
            <.language_select />
          </li>
          <li class={[maximize_search_bar? && "sr-only md:not-sr-only"]}>
            <.account_settings
              current_user={@current_user}
              account_link={@account_link}
              login_link={@login_link}
              user_management_implemented?={Fotohaecker.UserManagement.is_implemented?()}
            />
          </li>
        <% end %>
      </ul>
    </nav>
    """
  end

  defp reset_search(socket),
    do:
      socket
      |> assign(:search_query, "")
      |> assign(:grouped_search_results, nil)
      |> assign(:result_count, 0)

  def handle_event("search_reset", _unsigned_params, socket) do
    {:noreply, reset_search(socket)}
  end

  def handle_event("search", %{"search_query" => ""} = _unsigned_params, socket) do
    {:noreply, reset_search(socket)}
  end

  def handle_event("search", %{"search_query" => search_query} = _unsigned_params, socket) do
    search_results = Fotohaecker.Search.search!(search_query)
    result_count = length(search_results)

    grouped_search_results =
      Fotohaecker.Search.group_by_type(search_results)

    socket =
      socket
      |> assign(:search_query, search_query)
      |> assign(:grouped_search_results, grouped_search_results)
      |> assign(:result_count, result_count)

    {:noreply, socket}
  end
end
