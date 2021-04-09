defmodule SpeltWeb.R0.LoginControllerTest do
  use SpeltWeb.ConnCase

  alias Spelt.Auth

  describe "GET /_matrix/client/r0/login" do
    test "returns the supported login types", %{conn: conn} do
      conn = get(conn, Routes.login_path(conn, :show))

      assert json_response(conn, 200) == %{"flows" => [%{"type" => "m.login.password"}]}
    end
  end

  describe "POST /_matrix/client/r0/login" do
    test "with correct authentication, returns 200 and a token", %{conn: conn} do
      password = UUID.uuid4()
      {:ok, user} = Spelt.Repo.Node.create(build(:user, password: password))
      user_id = "@#{user.identifier}:#{Spelt.Config.hostname()}"
      device_id = UUID.uuid4()

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
               "device_id" => ^device_id
             } = json_response(response, 200)
    end

    test "with incorrect credentials, returns 403", %{conn: conn} do
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
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, _, %{access_token: token}} = Auth.create_session(user)

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.login_path(conn, :delete))

      assert %{} = json_response(response, 200)

      # When we try again, we should get a 401.
      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.login_path(conn, :delete))

      assert %{"errcode" => "M_UNKNOWN_TOKEN"} = json_response(response, 401)
    end
  end

  describe "POST /_matrix/client/r0/logout/all" do
    test "with a valid access token, invalidates all of the user's tokens and returns a 200", %{
      conn: conn
    } do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, _, %{access_token: token_1}} = Auth.create_session(user)
      {:ok, _, %{access_token: token_2}} = Auth.create_session(user)

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token_1}")
        |> post(Routes.login_path(conn, :delete_all))

      assert %{} = json_response(response, 200)

      # When we try again, we should get a 401.
      response =
        conn
        |> put_req_header("authorization", "Bearer #{token_1}")
        |> post(Routes.login_path(conn, :delete_all))

      assert %{"errcode" => "M_UNKNOWN_TOKEN"} = json_response(response, 401)

      # When we try another previously valid token for the user, we should get a 401.
      response =
        conn
        |> put_req_header("authorization", "Bearer #{token_2}")
        |> post(Routes.login_path(conn, :delete_all))

      assert %{"errcode" => "M_UNKNOWN_TOKEN"} = json_response(response, 401)
    end
  end
end
