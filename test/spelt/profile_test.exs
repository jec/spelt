defmodule Spelt.ProfileTest do
  use Spelt.Case

  alias Spelt.{Config, Profile}
  alias Spelt.Auth.User

  describe "Profile.get_display_name/1" do
    test "with local user ID, returns the display name" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      user_id = "@#{user.identifier}:#{Config.hostname()}"
      display_name = user.displayName

      assert ^display_name = Profile.get_display_name(user_id)
    end

    test "with unknown user ID, returns nil" do
      user_id = "@phred.smerd:#{Config.hostname()}"

      refute Profile.get_display_name(user_id)
    end
  end

  describe "Profile.set_display_name/2" do
    test "with matching user ID, returns :ok" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      user_id = "@#{user.identifier}:#{Config.hostname()}"
      display_name = "My New Display Name"

      assert :ok = Profile.set_display_name(user, user_id, display_name)
      assert %{displayName: ^display_name} = Spelt.Repo.Node.get(User, user.uuid)
    end

    test "with non-matching user ID, returns nil" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      user_id = "@phred.smerd:#{Config.hostname()}"
      display_name = "My New Display Name"

      assert :error = Profile.set_display_name(user, user_id, display_name)
    end
  end
end
