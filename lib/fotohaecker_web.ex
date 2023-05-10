defmodule FotohaeckerWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use FotohaeckerWeb, :controller
      use FotohaeckerWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """
  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt uploads)

  def router do
    quote do
      use Phoenix.Router

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.Component
      import Phoenix.LiveView.Router
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: FotohaeckerWeb.Layouts]

      import Plug.Conn

      import FotohaeckerWeb.Gettext

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {FotohaeckerWeb.Layouts, :app}

      # https://hexdocs.pm/phoenix_live_view/using-gettext.html
      defmodule RestoreLocale do
        @moduledoc false
        import Phoenix.LiveView

        def on_mount(:default, %{"locale" => locale} = _params, _session, socket) do
          Gettext.put_locale(FotohaeckerWeb.Gettext, locale)
          {:cont, socket}
        end

        def on_mount(:default, params, session, socket) do
          {:cont, socket}
        end
      end

      def handle_event("change_locale", %{"to" => locale}, socket) do
        Gettext.put_locale(FotohaeckerWeb.Gettext, locale)

        # right now, changing locale always redirects to homepage.
        # this could be improved with a plug strategy
        {:noreply, redirect(socket, to: FotohaeckerWeb.LiveHelpers.home_route())}
      end

      on_mount RestoreLocale

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import FotohaeckerWeb.CoreComponents
      import FotohaeckerWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS
      import FotohaeckerWeb.ErrorHelpers
      use Phoenix.HTML
      import Phoenix.Component
      import Phoenix.LiveView.Helpers
      import FotohaeckerWeb.LiveHelpers
      # import Phoenix.View

      import FotohaeckerWeb.ErrorHelpers
      import FotohaeckerWeb.Gettext
      alias FotohaeckerWeb.Router.Helpers, as: Routes

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  # defp html_helpers do
  #   quote do
  #     # HTML escaping functionality
  #     import Phoenix.HTML
  #     # Core UI components and translation
  #     import FotohaeckerWeb.CoreComponents
  #     import FotohaeckerWeb.Gettext

  #     # Shortcut for generating JS commands
  #     alias Phoenix.LiveView.JS

  #     # Use all HTML functionality (forms, tags, etc)
  #     use Phoenix.HTML

  #     # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
  #     import Phoenix.Component
  #     import Phoenix.LiveView.Helpers
  #     import FotohaeckerWeb.LiveHelpers

  #     # Import basic rendering functionality (render, render_layout, etc)
  #     import Phoenix.View
  #     alias Phoenix.LiveView.JS

  #     import FotohaeckerWeb.ErrorHelpers
  #     import FotohaeckerWeb.Gettext
  #     alias FotohaeckerWeb.Router.Helpers, as: Routes

  #     # Routes generation with the ~p sigil
  #     unquote(verified_routes())
  #   end
  # end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: FotohaeckerWeb.Endpoint,
        router: FotohaeckerWeb.Router,
        statics: FotohaeckerWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
