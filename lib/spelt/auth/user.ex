defmodule Spelt.Auth.User do
  @moduledoc """
  Represents a user
  """

  use Seraph.Schema.Node
  import Seraph.Changeset

  node "User" do
    property :identifier, :string
    property :encryptedPassword, :string
    property :name, :string
    property :email, :string
  end

  # TODO: This isn't working. Figure out how to do this.
  def __schema__(:redact_fields), do: [:password]

  def changeset(%Spelt.Auth.User{} = user, params \\ %{}) do
    user
    |> cast(params, [:identifier, :passwordHash, :name, :email])
  end
end
