defmodule Spelt.Session.User do
  @moduledoc """
  Represents a user
  """

  use Seraph.Schema.Node
  import Seraph.Changeset

  node "User" do
    property :identifier, :string
    property :password, :string
    property :name, :string
    property :email, :string
  end

  def changeset(%Spelt.Session.User{} = user, params \\ %{}) do
    user
    |> cast(params, [:identifier, :password, :name, :email])
    |> validate_required([:identifier, :password, :name, :email])
  end
end
