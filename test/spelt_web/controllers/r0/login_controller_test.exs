defmodule SpeltWeb.R0.LoginControllerTest do
  use SpeltWeb.ConnCase

  def create_user(username, password) do
    cypher = """
      CREATE (:User {user_id: '#{username}', password: '#{password}'})
    """
    {:ok, _} = Bolt.Sips.conn() |> Bolt.Sips.query(cypher)
  end

  describe "GET /_matrix/client/r0/login" do
    test "returns the supported login types", %{conn: conn} do
      conn = get(conn, Routes.login_path(conn, :show))

      assert json_response(conn, 200) == %{"flows" => [%{"type" => "m.login.password"}]}
    end
  end

  describe "POST /_matrix/client/r0/login" do
    test "with correct authentication, returns a 200 and a token", %{conn: conn} do
      username = "phred.smerd"
      user_id = "@#{username}:#{conn.host}"
      password = UUID.uuid4()
      device_id = "mydeviceid"

      create_user(username, password)

      params = %{
        type: "m.login.password",
        identifier: %{
          type: "m.id.user",
          user: user_id
        },
        password: password,
        device_id: device_id,
        initial_device_display_name: "My Device"
      }

      conn = post(conn, Routes.login_path(conn, :create), params)

      assert %{
        "user_id" => ^user_id,
        "access_token" => _,
        "device_id" => _
      } = json_response(conn, 200)

    end
  end
end
