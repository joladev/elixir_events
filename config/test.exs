import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :elixir_events, ElixirEvents.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "elixir_events_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :elixir_events, ElixirEventsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "a35QDnty2Lho4n2HQX2ri6Hca7f+6ppw4syECjJn9ZSiyPbGRhiZi72pgvmxtGE1",
  server: false

# In test we don't send emails
config :elixir_events, ElixirEvents.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Test credentials for Bluesky
config :elixir_events,
  bluesky_username: "test_user",
  bluesky_password: "test_password"

# Test credentials for push notifications
config :elixir_events,
  push_enabled: true,
  push_token: "test_token",
  push_group: "test_group"
