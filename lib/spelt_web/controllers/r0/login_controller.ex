defmodule SpeltWeb.R0.LoginController do
  use SpeltWeb, :controller

  def show(conn, _params) do
    json(conn, %{flows: Enum.map(Spelt.Session.login_types(), fn x -> %{type: x} end)})
  end

  def create(conn, params) do
    %{body: body, status: status} = Spelt.Session.log_in(conn, params)
    conn
    |> put_status(status)
    |> json(body)
  end
end
