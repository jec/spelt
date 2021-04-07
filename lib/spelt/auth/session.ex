defmodule Spelt.Auth.Session do
  @moduledoc """
  Represents an active user session
  """

  use Seraph.Schema.Node
  import Seraph.Changeset

  alias Spelt.Auth.Relationship.NoProperties

  node "Session" do
    property :jti, :string
    property :expiresAt, :utc_datetime

    incoming_relationship "AUTHENTICATED_AS",
                          Spelt.Auth.User,
                          :user,
                          NoProperties.UserToSession.AuthenticatedAs,
                          cardinality: :one
  end

  def changeset(%Spelt.Auth.Session{} = session, params \\ %{}) do
    session
    |> cast(params, [:jti, :expiresAt])
  end
end
