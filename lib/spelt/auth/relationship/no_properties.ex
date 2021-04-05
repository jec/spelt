defmodule Spelt.Auth.Relationship.NoProperties do
  import Seraph.Schema.Relationship

  alias Spelt.Auth.{Session, User}

  defrelationship "AUTHENTICATED_AS", User, Session, cardinality: [incoming: :one]
end
