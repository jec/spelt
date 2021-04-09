defmodule Spelt.AuthTest do
  use Spelt.Case

  alias Spelt.Auth
  alias Spelt.Auth.{Session, Token, User}
  alias Spelt.Auth.Relationship.NoProperties.UserToSession.AuthenticatedAs

  describe "Auth.create_session/3" do
    test "with a device_id, creates a Session with the given device_id" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      device_id = UUID.uuid4()
      user_id = "@#{user.identifier}:#{Spelt.Config.hostname()}"
      user_uuid = user.uuid

      assert {:ok, %Session{},
              %{
                user_id: ^user_id,
                access_token: token,
                device_id: ^device_id
              }} = Auth.create_session(user, device_id)

      assert {:ok, %{"sub" => ^user_uuid, "jti" => jti}} = Token.verify_and_validate(token)
      assert Spelt.Repo.Node.get_by(Session, jti: jti)
    end

    test "with no device_id, creates a Session with a new device_id" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      user_id = "@#{user.identifier}:#{Spelt.Config.hostname()}"
      user_uuid = user.uuid

      assert {:ok, %Session{},
              %{
                user_id: ^user_id,
                access_token: token,
                device_id: _
              }} = Auth.create_session(user)

      assert {:ok, %{"sub" => ^user_uuid, "jti" => jti}} = Token.verify_and_validate(token)
      assert Spelt.Repo.Node.get_by(Session, jti: jti)
    end
  end

  describe "Auth.get_user_and_session/2" do
    test "with matching user and session, returns {user, session}" do
      {:ok, %{uuid: user_uuid} = user} = Spelt.Repo.Node.create(build(:user))
      {:ok, %{jti: jti} = session} = Spelt.Repo.Node.create(build(:session))

      {:ok, _} =
        Spelt.Repo.Relationship.create(%AuthenticatedAs{start_node: user, end_node: session})

      assert {%User{uuid: ^user_uuid}, %Session{jti: ^jti}} =
               Auth.get_user_and_session(user_uuid, jti)
    end

    test "with no matching user, returns {}" do
      assert {} = Auth.get_user_and_session("foo", "bar")
    end
  end

  describe "Auth.login_types/0" do
    test "returns supported login types" do
      assert Auth.login_types() == ~w(m.login.password)
    end
  end

  describe "Auth.log_in/2" do
    test "with valid credentials and FQ user ID, returns :ok" do
      password = UUID.uuid4()
      {:ok, user} = Spelt.Repo.Node.create(build(:user, password: password))
      user_id = "@#{user.identifier}:#{Spelt.Config.hostname()}"

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => user_id
        },
        "password" => password,
        "initial_device_display_name" => "My Device"
      }

      assert {
               :ok,
               %Session{},
               %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: _
               }
             } = Auth.log_in(params)
    end

    test "with valid credentials and local identifier, returns :ok" do
      password = UUID.uuid4()
      {:ok, user} = Spelt.Repo.Node.create(build(:user, password: password))
      user_id = "@#{user.identifier}:#{Spelt.Config.hostname()}"

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => user.identifier
        },
        "password" => password,
        "initial_device_display_name" => "My Device"
      }

      assert {
               :ok,
               %Session{},
               %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: _
               }
             } = Auth.log_in(params)
    end

    test "with valid credentials and a device_id, returns :ok with the same device_id" do
      password = UUID.uuid4()
      {:ok, user} = Spelt.Repo.Node.create(build(:user, password: password))
      user_id = "@#{user.identifier}:#{Spelt.Config.hostname()}"
      device_id = UUID.uuid4()

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => user_id
        },
        "password" => password,
        "device_id" => device_id,
        "initial_device_display_name" => "My Device"
      }

      assert {
               :ok,
               %Session{},
               %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: ^device_id
               }
             } = Auth.log_in(params)
    end

    test "with invalid password, returns :forbidden" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      user_id = "@#{user.identifier}:#{Spelt.Config.hostname()}"

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => user_id
        },
        "password" => "bad-password",
        "initial_device_display_name" => "My Device"
      }

      assert {:error, :forbidden} = Auth.log_in(params)
    end

    test "with non-local user, returns :forbidden" do
      password = UUID.uuid4()
      {:ok, user} = Spelt.Repo.Node.create(build(:user, password: password))

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => "@#{user.identifier}:not-our-domain.net"
        },
        "password" => password,
        "initial_device_display_name" => "My Device"
      }

      assert {:error, :forbidden} = Auth.log_in(params)
    end

    test "with unknown user, returns :forbidden" do
      {:ok, _} = Spelt.Repo.Node.create(build(:user))

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => "non-existent-user"
        },
        "password" => "bad-password",
        "initial_device_display_name" => "My Device"
      }

      assert {:error, :forbidden} = Auth.log_in(params)
    end

    test "with no `type`, returns :bad_request" do
      assert {:error, :bad_request} = Auth.log_in(%{})
    end
  end

  describe "Auth.log_out/2" do
    test "with a valid token, invalidates the token and returns :ok" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, session, _} = Auth.create_session(user, "talk.example.cc")

      assert :ok = Auth.log_out(user, session)
      refute Spelt.Repo.Node.get(Session, session.uuid)
    end
  end

  describe "Auth.log_out_all/1" do
    test "with a valid token, invalidates all of the user's token and returns :ok" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, session_1, _} = Auth.create_session(user, "talk.example.cc")
      {:ok, session_2, _} = Auth.create_session(user, "talk.example.cc")

      assert :ok = Auth.log_out_all(user)
      refute Spelt.Repo.Node.get(Session, session_1.uuid)
      refute Spelt.Repo.Node.get(Session, session_2.uuid)
    end
  end
end
