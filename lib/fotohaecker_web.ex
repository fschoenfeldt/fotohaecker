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

  def controller do
    quote do
      use Phoenix.Controller, namespace: FotohaeckerWeb, formats: [:json]

      import Plug.Conn
      import FotohaeckerWeb.Gettext
      alias FotohaeckerWeb.Router.Helpers, as: Routes
      unquote(verified_routes())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/fotohaecker_web/templates",
        namespace: FotohaeckerWeb

      # import Phoenix.Component

      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: FotohaeckerWeb.Layouts]

      # Import convenience functions from controllers
      # import Phoenix.Controller,
      #   only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {FotohaeckerWeb.LayoutView, :live}

      def handle_event(
            "change_locale",
            %{"to" => to},
            socket
          ) do
        Gettext.put_locale(FotohaeckerWeb.Gettext, to)

        # TODO this didn't work when the current locale wasn't in the URI
        # from = Gettext.get_locale(FotohaeckerWeb.Gettext)
        # route = String.replace(socket.assigns.current_uri.path, from, to)
        # {:noreply, redirect(socket, to: route)}
        {:noreply, redirect(socket, to: FotohaeckerWeb.LiveHelpers.home_route())}
      end

      # on_mount(FotohaeckerWeb.OnMount.CurrentURI)
      on_mount(FotohaeckerWeb.OnMount.CurrentUser)
      on_mount(FotohaeckerWeb.OnMount.RestoreLocale)

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.Component
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import FotohaeckerWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
      import Phoenix.Component
      # import Phoenix.LiveView.Helpers
      import FotohaeckerWeb.LiveHelpers

      # Import basic rendering functionality (render, render_layout, etc)
      # import Phoenix.View
      alias Phoenix.LiveView.JS

      import FotohaeckerWeb.ErrorHelpers
      import FotohaeckerWeb.Gettext
      alias FotohaeckerWeb.Router.Helpers, as: Routes
      unquote(verified_routes())
    end
  end

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
