defmodule FotohaeckerWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use FotohaeckerWeb, :controller
      use FotohaeckerWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: FotohaeckerWeb

      import Plug.Conn
      import FotohaeckerWeb.Gettext
      alias FotohaeckerWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/fotohaecker_web/templates",
        namespace: FotohaeckerWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {FotohaeckerWeb.LayoutView, :live}

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
      import Phoenix.LiveView.Helpers
      import FotohaeckerWeb.LiveHelpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View
      alias Phoenix.LiveView.JS

      import FotohaeckerWeb.ErrorHelpers
      import FotohaeckerWeb.Gettext
      alias FotohaeckerWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
