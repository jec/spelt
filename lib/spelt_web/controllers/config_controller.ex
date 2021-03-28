defmodule SpeltWeb.ConfigController do
  use SpeltWeb, :controller

  def versions(conn, _params) do
    json(conn, %{versions: Spelt.Config.versions()})
  end
end
