defmodule Spelt.SessionTest do
  use ExUnit.Case

  alias Spelt.Session

  # TODO: Put this in a common Case module.
  setup _tags do
    on_exit(fn -> {:ok, _} = Bolt.Sips.conn() |> Bolt.Sips.query("MATCH (x) DETACH DELETE x") end)
  end

  def create_user(username, password) do
    cypher = """
      CREATE (:User {user_id: '#{username}', password: '#{password}'})
    """
    {:ok, _} = Bolt.Sips.conn() |> Bolt.Sips.query(cypher)
  end

  describe "Session.login_types/0" do
    test "returns supported login types" do
      assert Session.login_types() == ~w(m.login.password)
    end
  end

  describe "Session.log_in/2" do
    test "with valid credentials and FQ user ID, returns status 200" do
      host = "example.cc"
      username = "phred.smerd"
      user_id = "@#{username}:#{host}"
      password = UUID.uuid4()
      conn = %{host: host}

      create_user(username, password)

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

    test "with valid credentials and a device_id, returns status 200" do
      host = "example.cc"
      username = "phred.smerd"
      user_id = "@#{username}:#{host}"
      password = UUID.uuid4()
      conn = %{host: host}
      device_id = "mydeviceid"

      create_user(username, password)

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

    test "with invalid credentials, returns status 403" do
      host = "example.cc"
      username = "phred.smerd"
      user_id = "@#{username}:#{host}"
      password = UUID.uuid4()
      conn = %{host: host}

      create_user(username, password)

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
