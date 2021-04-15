defmodule Spelt.NotificationsTest do
  use Spelt.Case

  alias Spelt.Notifications.Pusher
  alias Spelt.Notifications.Relationship.NoProperties.UserToPusher.NotifiedBy

  describe "get_pushers/1" do
    test "returns the User's Pushers" do
      {:ok, user} = build(:user) |> Spelt.Repo.Node.create()
      {:ok, pusher_1} = build(:pusher) |> Spelt.Repo.Node.create()
      {:ok, pusher_2} = build(:pusher) |> Spelt.Repo.Node.create()
      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher_1})
      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher_2})
      expected_push_keys = MapSet.new([pusher_1.pushKey, pusher_2.pushKey])

      assert Spelt.Notifications.get_pushers(user)
             |> Enum.map(fn p -> p.pushKey end)
             |> MapSet.new()
             |> MapSet.equal?(expected_push_keys)
    end
  end

  describe "get_pusher/3" do
    test "with a matching Pusher, returns the Pusher" do
      {:ok, user} = build(:user) |> Spelt.Repo.Node.create()
      {:ok, pusher} = build(:pusher) |> Spelt.Repo.Node.create()
      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher})
      push_key = pusher.pushKey

      assert %Pusher{pushKey: ^push_key} =
               Spelt.Notifications.get_pusher(user, push_key, pusher.appId)
    end

    test "with no matching Pusher, returns nil" do
      {:ok, user} = build(:user) |> Spelt.Repo.Node.create()

      refute Spelt.Notifications.get_pusher(user, "foo", "bar")
    end
  end

  describe "put_pusher/2" do
    test "with `append: false`, and no matching existing Pusher, creates a Pusher and returns it" do
      {:ok, user} = build(:user) |> Spelt.Repo.Node.create()

      params = %{
        "pushkey" => UUID.uuid4(),
        "kind" => "email",
        "app_id" => "m.email",
        "app_display_name" => "My Matrix App",
        "device_display_name" => "Mobile",
        "lang" => "en",
        "data" => %{},
        "append" => false
      }

      assert {:ok, %Pusher{}} = Spelt.Notifications.put_pusher(user, params)
    end

    test "with `kind: nil`, deletes matching Pushers" do
      {:ok, user} = build(:user) |> Spelt.Repo.Node.create()
      {:ok, pusher} = build(:pusher) |> Spelt.Repo.Node.create()
      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher})

      assert {:ok, 1} = Spelt.Notifications.delete_pushers(user, pusher.pushKey, pusher.appId)
      refute Spelt.Notifications.get_pusher(user, pusher.pushKey, pusher.appId)
    end
  end

  describe "delete_pushers/3" do
    test "with matching Pushers, deletes the Pushers and returns a count" do
      {:ok, user} = build(:user) |> Spelt.Repo.Node.create()
      {:ok, pusher_1} = build(:pusher) |> Spelt.Repo.Node.create()

      {:ok, pusher_2} =
        build(:pusher, push_key: pusher_1.pushKey, app_id: pusher_1.appId)
        |> Spelt.Repo.Node.create()

      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher_1})
      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher_2})

      assert {:ok, 2} = Spelt.Notifications.delete_pushers(user, pusher_1.pushKey, pusher_1.appId)
      refute Spelt.Notifications.get_pusher(user, pusher_1.pushKey, pusher_1.appId)
    end
  end
end
