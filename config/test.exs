use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :spelt, SpeltWeb.Endpoint,
  http: [port: 4002],
  server: false

# Neo4j connection
config :bolt_sips, Bolt,
       url: "bolt://localhost:7697",
       basic_auth: [username: "neo4j", password: "9*Ep$Wy#Re8gK4oMggv"],
       pool_size: 10

# Print only warnings and errors during test
config :logger, level: :warn
