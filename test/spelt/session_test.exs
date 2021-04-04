defmodule Spelt.SessionTest do
  use Spelt.Case

  alias Spelt.Session

  describe "Session.login_types/0" do
    test "returns supported login types" do
      assert Session.login_types() == ~w(m.login.password)
    end
  end

  describe "Session.log_in/2" do
    test "with valid credentials and FQ user ID, returns status 200" do
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

      assert %{
               body: %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: _
               },
               status: 200
             } = Session.log_in(conn, params)
    end

    test "with valid credentials and local identifier, returns status 200" do
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

      assert %{
               body: %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: _
               },
               status: 200
             } = Session.log_in(conn, params)
    end

    test "with valid credentials and a device_id, returns the same device_id and status 200" do
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

      assert %{
               body: %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: ^device_id
               },
               status: 200
             } = Session.log_in(conn, params)
    end

    test "with invalid password, returns status 403" do
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

      assert %{
               body: %{
                 errcode: "M_FORBIDDEN"
               },
               status: 403
             } = Session.log_in(conn, params)
    end

    test "with unknown user, returns status 403" do
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

      assert %{
               body: %{
                 errcode: "M_FORBIDDEN"
               },
               status: 403
             } = Session.log_in(conn, params)
    end

    test "with no `type`, returns status 400" do
      conn = %{host: "example.net"}

      assert %{
               body: %{
                 errcode: "M_UNKNOWN"
               },
               status: 400
             } = Session.log_in(conn, %{})
    end
  end
end
