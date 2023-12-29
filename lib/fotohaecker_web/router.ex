defmodule FotohaeckerWeb.Router do
  use FotohaeckerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FotohaeckerWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug CORSPlug

    plug :accepts, ["json"]
  end

  pipeline :protected do
    plug FotohaeckerWeb.Plugs.RequireAuth
  end

  scope "/fh" do
    scope "/api", FotohaeckerWeb do
      pipe_through :api

      scope "/content" do
        get "/photos/:id", PhotoController, :show
        get "/photos", PhotoController, :index
      end

      scope "/search" do
        scope "/photos" do
          get "/:search", PhotoController, :search
        end
      end
    end
  end

  scope "/fh", FotohaeckerWeb do
    pipe_through :browser

    scope "/:locale/user" do
      pipe_through :protected
      live "/", UserLive.Index, :index

      # if Mix.env() in [:dev, :test] do
      #   get "/logs", AuthController, :logs
      # end

      post "/delete_account", AuthController, :delete_account
    end

    scope "/:locale/user" do
      live "/:id", UserLive.Show, :show
    end

    live "/", IndexLive.Home, :home
    live "/:locale", IndexLive.Home, :home
    live "/:locale/photos/:id", PhotoLive.Show, :show
    post "/:locale/search", SearchController, :search
    live "/:locale/search", SearchLive.Search, :index

    scope "/auth" do
      post "/logout", AuthController, :logout
      get "/login", AuthController, :login
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
      post "/:provider/callback", AuthController, :callback
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FotohaeckerWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
