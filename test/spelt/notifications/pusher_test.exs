defmodule Spelt.Notifications.PusherTest do
  use Spelt.Case
  import Seraph.Query

  alias Spelt.Auth.User
  alias Spelt.Notifications.Pusher
  alias Spelt.Notifications.Relationship.NoProperties.UserToPusher.NotifiedBy

  describe "(:User)-[:NOTIFIED_BY]->(:Pusher)" do
    test "with no related Pushers, returns an empty array" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))

      assert [] =
               match([
                 {u, User, %{uuid: user.uuid}},
                 {p, Pusher},
                 [{u}, [r, NotifiedBy], {p}]
               ])
               |> return([p])
               |> Spelt.Repo.all()
    end

    test "with multiple related Pushers, returns an array of all" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, pusher_1} = Spelt.Repo.Node.create(build(:pusher))
      {:ok, pusher_2} = Spelt.Repo.Node.create(build(:pusher))

      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher_1})
      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher_2})

      expected_push_keys = MapSet.new([pusher_1.pushKey, pusher_2.pushKey])

      assert match([
               {u, User, %{uuid: user.uuid}},
               {p, Pusher},
               [{u}, [r, NotifiedBy], {p}]
             ])
             |> return([p])
             |> Spelt.Repo.all()
             |> Enum.map(fn m -> m["p"] end)
             |> Enum.map(fn p -> p.pushKey end)
             |> MapSet.new()
             |> MapSet.equal?(expected_push_keys)
    end
  end
end
