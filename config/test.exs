use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :spelt, SpeltWeb.Endpoint,
  http: [port: 4002],
  server: false

# Neo4j connection through Seraph
config :spelt, Spelt.Repo,
  url: to_string(:os.getenv('TEST_DB_URL')),
  basic_auth: [username: "neo4j", password: to_string(:os.getenv('TEST_DB_PASSWORD'))],
  pool_size: 10

# Matrix /.well-known/matrix/client URLs
# `homeserver` is required; `identity_server` is optional.
config :spelt, :well_known, %{
  homeserver: "http://localhost:4000/"
}

# Joken
config :joken,
  default: [
    signer_alg: "RS256",
    key_pem: to_string(:os.getenv('TEST_JWT_KEY'))
  ]

# Print only warnings and errors during test
config :logger, level: :warn
