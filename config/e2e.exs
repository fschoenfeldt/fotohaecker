import Config

# Configure your database
config :fotohaecker, Fotohaecker.Repo,
  database: Path.expand("../fotohaecker_e2e.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fotohaecker, FotohaeckerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: System.get_env("PORT") || 1338],
  static_url: [path: "/fh"],
  check_origin: false,
  debug_errors: true,
  secret_key_base: "1NzYaIUQnsYa0OwKHW5KlwMSVS2IAWt8Zs9FMzLvl/tenDV0BIa3/El+LMt7mEid"

# In test we don't send emails.
config :fotohaecker, Fotohaecker.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
