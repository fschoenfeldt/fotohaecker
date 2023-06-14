defmodule FotohaeckerWeb.HeaderLive.NavigationComponent do
  @moduledoc false
  use FotohaeckerWeb, :live_component

  import __MODULE__.AccountSettings
  import __MODULE__.LanguageSelect
  import __MODULE__.Search

  def mount(socket) do
    {:ok,
     socket
     |> assign(:search_query, "")
     # Fotohaecker.Content.list_photos()
     |> assign(:search_results, nil)
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
        <li class="flex-1">
          <.search search_query={@search_query} search_results={@search_results} myself={@myself} />
        </li>
        <li>
          <.language_select />
        </li>
        <li>
          <.account_settings
            current_user={@current_user}
            account_link={@account_link}
            login_link={@login_link}
          />
        </li>
      </ul>
    </nav>
    """
  end

  defp reset_search(socket),
    do:
      socket
      |> assign(:search_query, "")
      |> assign(:search_results, nil)

  def handle_event("search_reset", _unsigned_params, socket) do
    {:noreply, reset_search(socket)}
  end

  def handle_event("search", %{"search_query" => ""} = _unsigned_params, socket) do
    {:noreply, reset_search(socket)}
  end

  def handle_event("search", %{"search_query" => search_query} = _unsigned_params, socket) do
    search_results = Fotohaecker.Content.search_photos(search_query)

    socket =
      socket
      |> assign(:search_query, search_query)
      |> assign(:search_results, search_results)

    {:noreply, socket}
  end
end
