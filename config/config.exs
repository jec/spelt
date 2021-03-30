# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :spelt, SpeltWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "L7zPpSXMyZsr56RPjWeFMWwk0SWlBb6S0I1h7VBJHeLqNPikovWICOtcRBkXyBsI",
  render_errors: [view: SpeltWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Spelt.PubSub,
  live_view: [signing_salt: "gbv7Xl5i"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :spelt, ecto_repos: [Spelt.Repo]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
