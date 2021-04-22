use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :spelt, SpeltWeb.Endpoint,
  http: [port: 4002],
  server: false

# Matrix /.well-known/matrix/client URLs
# `homeserver` is required; `identity_server` is optional.
config :spelt, :well_known, %{
  homeserver: "http://test.example.com/"
}

# Print only warnings and errors during test
config :logger, level: :warn
