defmodule Spelt.AuthTest do
  use Spelt.Case

  alias Spelt.Auth
  alias Spelt.Auth.{Session, Token, User}
  alias Spelt.Auth.Relationship.NoProperties.UserToSession.AuthenticatedAs

  describe "Auth.create_session/3" do
    test "with a device_id, creates a Session with the given device_id" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      device_id = UUID.uuid4()
      hostname = "chat.foo.net"
      user_id = "@#{user.identifier}:#{hostname}"
      user_uuid = user.uuid

      assert {:ok,
              %{
                user_id: ^user_id,
                access_token: token,
                device_id: ^device_id
              }} = Auth.create_session(user, hostname, device_id)

      assert {:ok, %{"sub" => ^user_uuid, "jti" => jti}} = Token.verify_and_validate(token)
      assert Spelt.Repo.Node.get_by(Session, jti: jti)
    end

    test "with no device_id, creates a Session with a new device_id" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      hostname = "chat.foo.net"
      user_id = "@#{user.identifier}:#{hostname}"
      user_uuid = user.uuid

      assert {:ok,
              %{
                user_id: ^user_id,
                access_token: token,
                device_id: _
              }} = Auth.create_session(user, hostname)

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
      host = "example.cc"
      identifier = "phred.smerd"
      user_id = "@#{identifier}:#{host}"
      password = UUID.uuid4()
      conn = %{host: host}

      {:ok, _} = Spelt.Repo.Node.create(build(:user, identifier: identifier, password: password))

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
               %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: _
               }
             } = Auth.log_in(conn, params)
    end

    test "with valid credentials and local identifier, returns :ok" do
      host = "example.cc"
      identifier = "phred.smerd"
      user_id = "@#{identifier}:#{host}"
      password = UUID.uuid4()
      conn = %{host: host}

      {:ok, _} = Spelt.Repo.Node.create(build(:user, identifier: identifier, password: password))

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => identifier
        },
        "password" => password,
        "initial_device_display_name" => "My Device"
      }

      assert {
               :ok,
               %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: _
               }
             } = Auth.log_in(conn, params)
    end

    test "with valid credentials and a device_id, returns :ok with the same device_id" do
      host = "example.cc"
      identifier = "phred.smerd"
      user_id = "@#{identifier}:#{host}"
      password = UUID.uuid4()
      conn = %{host: host}
      device_id = UUID.uuid4()

      {:ok, _} = Spelt.Repo.Node.create(build(:user, identifier: identifier, password: password))

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
               %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: ^device_id
               }
             } = Auth.log_in(conn, params)
    end

    test "with invalid password, returns :forbidden" do
      host = "example.cc"
      identifier = "phred.smerd"
      user_id = "@#{identifier}:#{host}"
      conn = %{host: host}

      {:ok, _} = Spelt.Repo.Node.create(build(:user, identifier: identifier))

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => user_id
        },
        "password" => "bad-password",
        "initial_device_display_name" => "My Device"
      }

      assert {:error, :forbidden} = Auth.log_in(conn, params)
    end

    test "with non-local user, returns :forbidden" do
      host = "example.cc"
      conn = %{host: host}

      {:ok, user} = Spelt.Repo.Node.create(build(:user))

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => "@#{user.identifier}:not-our-domain.net"
        },
        "password" => "bad-password",
        "initial_device_display_name" => "My Device"
      }

      assert {:error, :forbidden} = Auth.log_in(conn, params)
    end

    test "with unknown user, returns :forbidden" do
      host = "example.cc"
      conn = %{host: host}

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

      assert {:error, :forbidden} = Auth.log_in(conn, params)
    end

    test "with no `type`, returns :bad_request" do
      conn = %{host: "example.net"}

      assert {:error, :bad_request} = Auth.log_in(conn, %{})
    end
  end

  describe "Auth.log_out/1" do
    test "with a valid token, invalidates the token and returns :ok" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))

      {
        :ok,
        %{
          user_id: _,
          access_token: token,
          device_id: _
        }
      } = Auth.create_session(user, "talk.example.cc")

      assert :ok = Auth.log_out(token)

      # A second call should fail.
      assert :error = Auth.log_out(token)
    end
  end

  describe "Auth.log_out_all/1" do
    test "with a valid token, invalidates all of the user's token and returns :ok" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))

      {:ok,
       %{
         user_id: _,
         access_token: token_1,
         device_id: _
       }} = Auth.create_session(user, "talk.example.cc")

      {:ok,
       %{
         user_id: _,
         access_token: token_2,
         device_id: _
       }} = Auth.create_session(user, "talk.example.cc")

      assert :ok = Auth.log_out_all(token_1)

      # A second call should fail.
      assert :error = Auth.log_out_all(token_1)

      # A call with another previously valid token should fail.
      assert :error = Auth.log_out_all(token_2)
    end
  end
end
