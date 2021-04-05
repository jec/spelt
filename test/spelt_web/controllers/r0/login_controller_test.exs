defmodule SpeltWeb.R0.LoginControllerTest do
  use SpeltWeb.ConnCase

  describe "GET /_matrix/client/r0/login" do
    test "returns the supported login types", %{conn: conn} do
      conn = get(conn, Routes.login_path(conn, :show))

      assert json_response(conn, 200) == %{"flows" => [%{"type" => "m.login.password"}]}
    end
  end

  describe "POST /_matrix/client/r0/login" do
    test "with correct authentication, returns 200 and a token", %{conn: conn} do
      identifier = "phred.smerd"
      user_id = "@#{identifier}:#{conn.host}"
      password = UUID.uuid4()
      device_id = UUID.uuid4()

      {:ok, _} = Spelt.Repo.Node.create(build(:user, identifier: identifier, password: password))

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

      response = post(conn, Routes.login_path(conn, :create), params)

      assert %{
               "user_id" => ^user_id,
               "access_token" => _,
               "device_id" => ^device_id,
             } = json_response(response, 200)
    end

    test "with incorrect authentication, returns 403", %{conn: conn} do
      params = %{
        type: "m.login.password",
        identifier: %{
          type: "m.id.user",
          user: "phred.smerd"
        },
        password: UUID.uuid4(),
        initial_device_display_name: "My Device"
      }

      response = post(conn, Routes.login_path(conn, :create), params)

      assert %{"errcode" => "M_FORBIDDEN"} = json_response(response, 403)
    end
  end

  describe "POST /_matrix/client/r0/logout" do
    test "with a valid access token, invalidates the token and returns a 200", %{conn: conn} do
      token = UUID.uuid4()

      response = conn
             |> put_req_header("authorization", "Bearer #{token}")
             |> post(Routes.login_path(conn, :delete))

      assert json_response(response, 200) == %{}

      # When we try again, we should get a 403.
      response = conn
                 |> put_req_header("authorization", "Bearer #{token}")
                 |> post(Routes.login_path(conn, :delete))

      assert %{"errcode" => "M_FORBIDDEN"} = json_response(response, 403)
    end
  end
end
