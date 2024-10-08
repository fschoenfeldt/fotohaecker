# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :fotohaecker,
  ecto_repos: [Fotohaecker.Repo]

# Configures the endpoint
config :fotohaecker, FotohaeckerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: FotohaeckerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Fotohaecker.PubSub,
  live_view: [signing_salt: "Uo5H/hq4"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :fotohaecker, Fotohaecker.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.23.0",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Tailwind
config :tailwind,
  version: "3.4.9",
  default: [
    args: ~w(
    --postcss
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :fotohaecker,
       FotohaeckerWeb.Gettext,
       locales: ["en_US", "de_DE"],
       default_locale: "en_US"

config :ueberauth, Ueberauth,
  base_path: "/fh/auth",
  providers: [
    auth0: {Ueberauth.Strategy.Auth0, []}
  ]

config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
  domain: System.get_env("AUTH0_DOMAIN"),
  client_id: System.get_env("AUTH0_CLIENT_ID"),
  client_secret: System.get_env("AUTH0_CLIENT_SECRET")

# Configure Swagger
config :fotohaecker, :phoenix_swagger,
  swagger_files: %{
    "priv/static/schema.json" => [
      # phoenix routes will be converted to swagger paths
      router: FotohaeckerWeb.Router,
      # (optional) endpoint config used to set host, port and https schemes.
      endpoint: FotohaeckerWeb.Endpoint
    ]
  }

config :phoenix_swagger,
  json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
