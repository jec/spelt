defmodule Spelt.SessionTest do
  use Spelt.Case

  alias Spelt.Session

  describe "Session.login_types/0" do
    test "returns supported login types" do
      assert Session.login_types() == ~w(m.login.password)
    end
  end

  describe "Session.log_in/2" do
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
             } = Session.log_in(conn, params)
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
             } = Session.log_in(conn, params)
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
             } = Session.log_in(conn, params)
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

      assert {:error, :forbidden} = Session.log_in(conn, params)
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

      assert {:error, :forbidden} = Session.log_in(conn, params)
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

      assert {:error, :forbidden} = Session.log_in(conn, params)
    end

    test "with no `type`, returns :bad_request" do
      conn = %{host: "example.net"}

      assert {:error, :bad_request} = Session.log_in(conn, %{})
    end
  end

  describe "Session.log_out/1" do
    test "with a valid token, invalidates the token and returns :ok" do
      token = UUID.uuid4()

      assert :ok = Session.log_out(token)

      # A second call should fail.
      assert :error = Session.log_out(token)
    end
  end
end
