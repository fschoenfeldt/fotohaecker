import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :fotohaecker, Fotohaecker.Repo,
  database: Path.expand("../fotohaecker_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fotohaecker, FotohaeckerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "1NzYaIUQnsYa0OwKHW5KlwMSVS2IAWt8Zs9FMzLvl/tenDV0BIa3/El+LMt7mEid",
  server: false

# In test we don't send emails.
config :fotohaecker, Fotohaecker.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
