use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :line_server, LineServerWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :line_server, line_path: System.get_env("LINE_PATH") || "small_test.txt"
