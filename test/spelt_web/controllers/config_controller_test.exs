defmodule SpeltWeb.ConfigControllerTest do
  use SpeltWeb.ConnCase

  describe "GET /_matrix/client/versions" do
    test "returns the supported client/server versions", %{conn: conn} do
      expected_versions = Spelt.Config.versions()
      conn = get(conn, Routes.config_path(conn, :versions))

      assert json_response(conn, 200) == %{"versions" => expected_versions}
    end
  end
end
