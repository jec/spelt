defmodule SpeltWeb.ConfigControllerTest do
  use SpeltWeb.ConnCase

  describe "GET /_matrix/client/versions" do
    test "returns the supported client/server versions", %{conn: conn} do
      expected_versions = Spelt.Config.versions()
      response = get(conn, Routes.config_path(conn, :versions))

      assert json_response(response, 200) == %{"versions" => expected_versions}
    end
  end

  describe "GET /.well-known/matrix/client" do
    setup do
      previous_well_known = Application.get_env(:spelt, :well_known)
      on_exit(fn -> Application.put_env(:spelt, :well_known, previous_well_known) end)
    end

    test "with hostname and identity server configured, returns both", %{conn: conn} do
      hostname = "chat.foobaz.net"
      id_server = "id.example.cc"

      Application.put_env(:spelt, :well_known, %{homeserver: hostname, identity_server: id_server})

      response = get(conn, Routes.config_path(conn, :well_known))

      assert %{
               "m.homeserver" => %{"base_url" => ^hostname},
               "m.identity_server" => %{"base_url" => ^id_server}
             } = json_response(response, 200)
    end

    test "with hostname and identity server unconfigured, returns 404", %{conn: conn} do
      Application.delete_env(:spelt, :well_known)

      response = get(conn, Routes.config_path(conn, :well_known))

      assert json_response(response, 404)
    end

    test "with identity server configured, returns 404", %{conn: conn} do
      Application.put_env(:spelt, :well_known, %{identity_server: "foo.bar.net"})

      response = get(conn, Routes.config_path(conn, :well_known))

      assert json_response(response, 404)
    end
  end
end
