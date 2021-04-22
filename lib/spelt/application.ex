defmodule Spelt.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Load Vapor config.
    providers = [
      %Vapor.Provider.File{path: "config/#{Mix.env()}.yaml", bindings: [db: "db", jwt: "jwt"]}
    ]

    vapor_config = Vapor.load!(providers)

    # Set config for Spelt.Repo.
    neo4j_config = [
      url: vapor_config.db["url"],
      basic_auth: [username: vapor_config.db["username"], password: vapor_config.db["password"]],
      pool_size: vapor_config.db["pool_size"]
    ]

    Application.put_env(:spelt, Spelt.Repo, neo4j_config)

    # Set config for Joken.
    joken_config = [
      signer_alg: vapor_config.jwt["algorithm"],
      key_pem: vapor_config.jwt["key"]
    ]

    Application.put_env(:joken, :default, joken_config)

    children = [
      # Start the Telemetry supervisor
      SpeltWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Spelt.PubSub},
      # Start the Neo4j repo
      Spelt.Repo,
      {Bolt.Sips, neo4j_config},
      # Start the Endpoint (http/https)
      SpeltWeb.Endpoint
      # Start a worker by calling: Spelt.Worker.start_link(arg)
      # {Spelt.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Spelt.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SpeltWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
