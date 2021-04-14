defmodule Spelt.Auth.User do
  @moduledoc """
  Represents a user
  """

  use Seraph.Schema.Node
  import Seraph.Changeset

  alias Spelt.Auth.Relationship.NoProperties.UserToSession.AuthenticatedAs
  alias Spelt.Notifications.Relationship.NoProperties.UserToPusher.NotifiedBy

  node "User" do
    property :identifier, :string
    property :encryptedPassword, :string
    property :displayName, :string
    property :email, :string

    outgoing_relationship "AUTHENTICATED_AS",
                          Spelt.Auth.Session,
                          :sessions,
                          AuthenticatedAs,
                          cardinality: :many

    outgoing_relationship "NOTIFIED_BY",
                          Spelt.Notifications.Pusher,
                          :pushers,
                          NotifiedBy,
                          cardinality: :many
  end

  # TODO: This isn't working. Figure out how to do this.
  def __schema__(:redact_fields), do: [:password]

  def changeset(%Spelt.Auth.User{} = user, params \\ %{}) do
    user
    |> cast(params, [:identifier, :encryptedPassword, :displayName, :email])
  end
end
