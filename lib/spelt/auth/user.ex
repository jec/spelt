defmodule Spelt.Auth.User do
  @moduledoc """
  Represents a user
  """

  use Seraph.Schema.Node
  import Seraph.Changeset

  alias Spelt.Auth.Relationship.NoProperties

  node "User" do
    property :identifier, :string
    property :encryptedPassword, :string
    property :name, :string
    property :email, :string

    outgoing_relationship "AUTHENTICATED_AS",
                          Spelt.Auth.Session,
                          :sessions,
                          NoProperties.UserToSession.AuthenticatedAs,
                          cardinality: :many
  end

  # TODO: This isn't working. Figure out how to do this.
  def __schema__(:redact_fields), do: [:password]

  def changeset(%Spelt.Auth.User{} = user, params \\ %{}) do
    user
    |> cast(params, [:identifier, :passwordHash, :name, :email])
  end
end
