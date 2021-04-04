defmodule Spelt.Repo do
  @moduledoc """
  Manages interactions with the Neo4j database
  """

  use Seraph.Repo, otp_app: :spelt
end
