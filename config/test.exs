import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :novy, Novy.Repo,
  username: "postgres",
  password: "pass",
  hostname: "localhost",
  database: "novy_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :novy_web, NovyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4040],
  secret_key_base: "8CBGaVXTrMfnarGpIlRgnBVRJYd/0CVuVwgYSPpCUj+vWpTBb/3ru8fuqa42+mOr",
  server: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :novy_admin, NovyAdmin.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4041],
  secret_key_base: "muyCCD7KwhyvNdE+k0pfUr488C3BvwnRp+FyiU7izEgkg9u/BSo6kcBGOg0fLxxi",
  server: false

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :novy_api, NovyApi.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4042],
  secret_key_base: "zoDkNnC8tRew8AwMx3WVsr9SUUZHrPYmGu7JYFnWUbDNWUJYLPVuUEqkuGP/Gezo",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# In test we don't send emails.
config :novy, Novy.Mailer, adapter: Swoosh.Adapters.Test

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
