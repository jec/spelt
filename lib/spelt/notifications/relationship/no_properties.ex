defmodule Spelt.Notifications.Relationship.NoProperties do
  @moduledoc """
  Defines Relationships that have no properties
  """

  import Seraph.Schema.Relationship

  alias Spelt.Auth.User
  alias Spelt.Notifications.Pusher

  defrelationship "NOTIFIED_BY", User, Pusher, cardinality: [incoming: :one]
end
