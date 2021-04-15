defmodule Spelt.Notifications.Pusher do
  @moduledoc """
  Represents a push notification source configured for a User
  """

  use Seraph.Schema.Node
  import Seraph.Changeset

  alias Spelt.Notifications.Relationship.NoProperties.UserToPusher.NotifiedBy

  @type t :: %Spelt.Notifications.Pusher{
          pushKey: String.t(),
          kind: String.t(),
          appId: String.t(),
          appDisplayName: String.t(),
          deviceDisplayName: String.t(),
          profileTag: String.t(),
          lang: String.t(),
          data: String.t()
        }

  node "Pusher" do
    property :pushKey, :string
    property :kind, :string
    property :appId, :string
    property :appDisplayName, :string
    property :deviceDisplayName, :string
    property :profileTag, :string
    property :lang, :string
    # TODO: The datatype :map doesn't work.
    property :data, :string

    incoming_relationship "NOTIFIED_BY",
                          Spelt.Auth.User,
                          :user,
                          NotifiedBy,
                          cardinality: :one
  end

  def changeset(%Spelt.Notifications.Pusher{} = pusher, params \\ %{}) do
    pusher
    |> cast(params, [
      :pushKey,
      :kind,
      :appId,
      :appDisplayName,
      :deviceDisplayName,
      :profileTag,
      :lang,
      :data
    ])
    |> validate_required([
      :pushKey,
      :kind,
      :appId,
      :appDisplayName,
      :deviceDisplayName,
      :lang,
      :data
    ])
  end
end

defimpl Jason.Encoder, for: Spelt.Notifications.Pusher do
  # Keys to include in the JSON output
  @keep [
    :pushKey,
    :kind,
    :appId,
    :appDisplayName,
    :deviceDisplayName,
    :profileTag,
    :lang,
    :data
  ]

  # Keys that need renaming
  @keymap %{
    pushKey: :pushkey,
    kind: :kind,
    appId: :app_id,
    appDisplayName: :app_display_name,
    deviceDisplayName: :device_display_name,
    profileTag: :profile_tag,
    lang: :lang,
    data: :data
  }

  def encode(value, opts) do
    value
    |> Map.take(@keep)
    |> Map.new(fn {key, value} -> {@keymap[key], value} end)
    |> Jason.Encode.map(opts)
  end
end
