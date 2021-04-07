defmodule SpeltWeb.ConfigController do
  use SpeltWeb, :controller

  require Logger

  def versions(conn, _params) do
    json(conn, %{versions: Spelt.Config.versions()})
  end

  def well_known(conn, _params) do
    case Application.get_env(:spelt, :well_known) do
      %{homeserver: hostname, identity_server: id_server} ->
        conn
        |> put_status(200)
        |> json(%{
          "m.homeserver" => %{"base_url" => hostname},
          "m.identity_server" => %{"base_url" => id_server}
        })

      %{homeserver: hostname} ->
        conn
        |> put_status(200)
        |> json(%{
          "m.homeserver" => %{"base_url" => hostname}
        })

      _ ->
        Logger.warn("Well-known client URLs are not configured.")

        conn
        |> put_status(404)
        |> json(%{})
    end
  end
end
