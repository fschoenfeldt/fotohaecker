defmodule FotohaeckerWeb.HeaderLive.NavigationComponent do
  @moduledoc false
  use FotohaeckerWeb, :live_component

  import FotohaeckerWeb.HeaderLive.NavigationComponent.AccountSettings
  import FotohaeckerWeb.HeaderLive.NavigationComponent.LanguageSelect
  # import FotohaeckerWeb.HeaderLive.NavigationComponent.Search

  def mount(socket) do
    {:ok,
     socket
     |> assign(:search, "")
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
          <%!-- <.search search={@search} myself={@myself} /> --%>
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

  def handle_event("search", unsigned_params, socket) do
    {:noreply, assign(socket, :search, unsigned_params["search"])}
  end
end
