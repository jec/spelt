defmodule SpeltWeb.ProfileControllerTest do
  use SpeltWeb.ConnCase

  alias Spelt.{Auth, Config}
  alias Spelt.Auth.User

  describe "GET /_matrix/client/r0/profile/:user_id/displayname" do
    test "with a valid local user_id, returns the display name", %{conn: conn} do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      user_id = "@#{user.identifier}:#{Spelt.Config.hostname()}"
      display_name = user.displayName

      response = get(conn, Routes.profile_path(conn, :show_display_name, user_id))

      assert %{"displayname" => ^display_name} = json_response(response, 200)
    end

    test "with an unknown user_id, returns an empty response", %{conn: conn} do
      user_id = "@phred.smerd:#{Spelt.Config.hostname()}"

      response = get(conn, Routes.profile_path(conn, :show_display_name, user_id))

      assert json_response(response, 404)
    end
  end

  describe "PUT /_matrix/client/r0/profile/:user_id/displayname" do
    test "with a valid local user_id and matching credentials, returns 200", %{conn: conn} do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, _, %{access_token: token}} = Auth.create_session(user, Config.hostname())
      user_id = "@#{user.identifier}:#{Config.hostname()}"
      display_name = "My New Display Name"
      params = %{displayname: display_name}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(Routes.profile_path(conn, :update_display_name, user_id), params)

      assert json_response(response, 200)
      assert %{displayName: ^display_name} = Spelt.Repo.Node.get(User, user.uuid)
    end

    test "with mismatched user_id and credentials, returns 403", %{conn: conn} do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, _, %{access_token: token}} = Auth.create_session(user, Config.hostname())
      user_id = "@phred.smerd:#{Config.hostname()}"
      display_name = "My New Display Name"
      params = %{displayname: display_name}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> put(Routes.profile_path(conn, :update_display_name, user_id), params)

      assert %{"errcode" => "M_FORBIDDEN"} = json_response(response, 403)
    end
  end
end
