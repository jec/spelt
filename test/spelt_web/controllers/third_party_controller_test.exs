defmodule SpeltWeb.ThirdPartyControllerTest do
  use SpeltWeb.ConnCase

  alias Spelt.{Auth, Config}

  describe "GET /_matrix/client/r0/thirdparty/protocols" do
    test "with valid credentials, returns an empty object", %{conn: conn} do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, _, %{access_token: token}} = Auth.create_session(user, Config.hostname())

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(Routes.third_party_path(conn, :protocol_index))

      assert json_response(response, 200) == %{}
    end

    test "with no credentials, returns an empty object", %{conn: conn} do
      response = get(conn, Routes.third_party_path(conn, :protocol_index))
      assert json_response(response, 401)
    end
  end
end
