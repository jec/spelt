defmodule Spelt.Notifications do
  @moduledoc """
  Implements actions related to push notifications and their configuration
  """

  import Seraph.Query
  require Logger

  alias Spelt.Auth.User
  alias Spelt.Notifications.Pusher
  alias Spelt.Notifications.Relationship.NoProperties.UserToPusher.NotifiedBy

  @doc """
  Returns a list of Pushers related to a User
  """
  @spec get_pushers(User.t()) :: [Pusher.t()]
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

  @doc """
  Returns a Pusher related to a User with a particular `push_key` and `app_id`;
  or `nil` if not found
  """
  @spec get_pusher(User.t(), String.t(), String.t()) :: nil | Pusher.t()
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

  @doc """
  Creates, updates or deletes a Pusher, depending on the values in `params`
  """
  @spec put_pusher(User.t(), map()) :: {:ok, Pusher.t() | non_neg_integer()}
  def put_pusher(user, %{"kind" => nil, "pushkey" => push_key, "app_id" => app_id}) do
    delete_pushers(user, push_key, app_id)
  end

  def put_pusher(user, %{"append" => false, "pushkey" => push_key, "app_id" => app_id} = params) do
    with(
      # Delete any matching Pushers first.
      {:ok, _} <- delete_pushers(user, push_key, app_id),
      # Create the new Pusher.
      {:ok, pusher} <-
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
    ) do
      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher})
      Logger.info("Created Pusher #{pusher.uuid}")
      {:ok, pusher}
    else
      error ->
        Logger.warn("Failed to create Pusher: #{inspect(error)}")
        error
    end
  end

  @doc """
  Deletes a Pusher belonging to a specified User with matching `push_key` and
  `app_id`
  """
  @spec delete_pushers(User.t(), String.t(), String.t()) :: {:ok, non_neg_integer()}
  def delete_pushers(user, push_key, app_id) do
    case match([
           {u, User, %{uuid: user.uuid}},
           {p, Pusher, %{pushKey: push_key, appId: app_id}},
           [{u}, [r, NotifiedBy], {p}]
         ])
         |> delete([p])
         |> Spelt.Repo.execute(with_stats: true) do
      {:ok, %{stats: %{"nodes-deleted" => count}}} ->
        Logger.info("Deleted #{count} Pushers")
        {:ok, count}

      {:ok, %{stats: []}} ->
        Logger.info("Deleted no Pushers")
        {:ok, 0}
    end
  end
end
