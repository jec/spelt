defmodule SpeltWeb.R0.LoginController do
  use SpeltWeb, :controller

  @token_pattern  ~r/^Bearer (.+)$/

  @response_400 %{
    errcode: "M_UNKNOWN",
    error: "Unsupported or missing login type"
  }

  @response_403 %{errcode: "M_FORBIDDEN"}

  def show(conn, _params) do
    json(conn, %{flows: Enum.map(Spelt.Session.login_types(), fn x -> %{type: x} end)})
  end

  def create(conn, params) do
    case Spelt.Session.log_in(conn, params) do
      {:ok, body} ->
        conn
        |> put_status(200)
        |> json(body)
      {:error, :forbidden} ->
        conn
        |> put_status(403)
        |> json(@response_403)
      {:error, :bad_request} ->
        conn
        |> put_status(400)
        |> json(@response_400)
    end
  end

  def delete(conn, _params) do
    case Plug.Conn.get_req_header(conn, "authorization") do
      [] -> Spelt.Session.log_out(nil)
      [auth] ->
        case Regex.run(@token_pattern, auth) do
          [] -> Spelt.Session.log_out(nil)
          [_, token] -> Spelt.Session.log_out(token)
        end
    end

    conn
    |> put_status(200)
    |> json(%{})
  end
end
