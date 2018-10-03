# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :line_server, LineServerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "yO9PeaGeYuJ3uarjsIr73zXXoXprapgazh0rFHST/88MjYdCdo3S8DXEHV7P5TdP",
  render_errors: [view: LineServerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: LineServer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :line_server, line_path: System.get_env("LINE_PATH") || "test.txt"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

