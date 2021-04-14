defmodule Spelt.Notifications do
  @moduledoc """
  Implements actions related to push notifications and their configuration
  """

  import Seraph.Query
  require Logger

  alias Spelt.Auth.User
  alias Spelt.Notifications.Pusher
  alias Spelt.Notifications.Relationship.NoProperties.UserToPusher.NotifiedBy

  def get_pushers(user) do
    match([
      {u, User, %{uuid: user.uuid}},
      {p, Pusher},
      [{u}, [r, NotifiedBy], {p}]
    ])
    |> return([p])
    |> Spelt.Repo.all()
    |> Enum.map(fn m -> m["p"] end)
  end

  def get_pusher(user, push_key, app_id) do
    with(
      %{"p" => pusher} <-
        match([
          {u, User, %{uuid: user.uuid}},
          {p, Pusher, %{pushKey: push_key, appId: app_id}},
          [{u}, [r, NotifiedBy], {p}]
        ])
        |> return([p])
        |> Spelt.Repo.one()
    ) do
      pusher
    else
      _ -> nil
    end
  end

  def put_pusher(user, %{"kind" => nil} = params) do
  end

  def put_pusher(user, %{"append" => false, "pushkey" => push_key, "app_id" => app_id} = params) do
    # Delete any matching Pushers first.
    {:ok, _} = delete_pushers(user, push_key, app_id)

    # Create the new Pusher.
    %Pusher{
      pushKey: push_key,
      kind: params["kind"],
      appId: app_id,
      appDisplayName: params["app_display_name"],
      deviceDisplayName: params["device_display_name"],
      profileTag: params["profile_tag"],
      lang: params["lang"],
      data: params["data"] |> Jason.encode!(params["data"])
    }
    |> Spelt.Repo.Node.create()
  end

  def delete_pushers(user, push_key, app_id) do
    case match([
        {u, User, %{uuid: user.uuid}},
        {p, Pusher, %{pushKey: push_key, appId: app_id}},
        [{u}, [r, NotifiedBy], {p}]
      ])
      |> delete([p])
      |> Spelt.Repo.execute(with_stats: true)
    do
      {:ok, %{stats: %{"nodes-deleted" => count}}} ->
        {:ok, count}
      {:ok, %{stats: []}} ->
        {:ok, 0}
    end
  end
end
