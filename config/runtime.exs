import Config
require Logger

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# TODO: these env lists are getting out of hand…
if System.get_env("STRIPE_SECRET") do
  config :stripity_stripe,
    api_key: System.get_env("STRIPE_SECRET"),
    connect_client_id: System.get_env("STRIPE_CONNECT_CLIENT_ID")

  config :fotohaecker, Fotohaecker.Payment,
    implementation: Fotohaecker.Payment.StripePayment,
    price_id: System.get_env("STRIPE_PRICE_ID")
else
  Logger.info("No STRIPE_SECRET found, using NoPayment")
end

# Configure image detection here
# in case you don't provide a config, the NoDetection module will be used
if System.get_env("CLARIFAI_API_SECRET") do
  config :fotohaecker, Fotohaecker.TagDetection, Fotohaecker.TagDetection.Clarifai
end

api_cors_origins =
  if System.get_env("API_CORS_ORIGINS") do
    "API_CORS_ORIGINS"
    |> System.get_env()
    |> String.split(",")
  else
    Logger.info(
      "No API_CORS_ORIGINS configured, API probably won't be accessible from other domains"
    )

    []
  end

# TODO: don't hardcode
config :cors_plug,
  origin: api_cors_origins,
  max_age: 86_400,
  methods: ["GET"]

# TODO remove double boolean
# TODO: these env lists are getting out of hand…
if !!System.get_env("AUTH0_DOMAIN") and !!System.get_env("AUTH0_MANAGEMENT_CLIENT_ID") and
     !!System.get_env("AUTH0_MANAGEMENT_CLIENT_SECRET") do
  config :fotohaecker,
         Fotohaecker.UserManagement,
         Fotohaecker.UserManagement.Auth0UserManagement
else
  Logger.info(
    "No AUTH0_DOMAIN, AUTH0_MANAGEMENT_CLIENT_ID or AUTH0_MANAGEMENT_CLIENT_SECRET found, using NoUserManagement"
  )
end

if System.get_env("RECIPE_IMPLEMENTATION") do
  if System.get_env("RECIPE_IMPLEMENTATION") == "json" do
    if System.get_env("RECIPE_PATH") do
      config :fotohaecker,
             Fotohaecker.RecipeManagement,
             Fotohaecker.RecipeManagement.JsonRecipeManagement

      config :fotohaecker, Fotohaecker.RecipeManagement.JsonRecipeManagement,
        recipe_path: System.get_env("RECIPE_PATH")
    else
      Logger.error(
        "RECIPE_IMPLEMENTATION is set to json, but RECIPE_PATH is missingm, using NoRecipeManagement"
      )
    end
  end
else
  Logger.info("No RECIPE_PATH and RECIPE_IMPLEMENTATION found, using NoRecipeManagement")
end

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/fotohaecker start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :fotohaecker, FotohaeckerWeb.Endpoint, server: true
end

if config_env() == :test do
  config :fotohaecker, Fotohaecker.RecipeManagement.JsonRecipeManagement, warm: false
end

if config_env() == :prod do
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      environment variable DATABASE_PATH is missing.
      For example: /etc/fotohaecker/fotohaecker.db
      """

  config :fotohaecker, Fotohaecker.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :fotohaecker, FotohaeckerWeb.Endpoint,
    url: [host: host, scheme: "https", port: 443],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :fotohaecker, Fotohaecker.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end
