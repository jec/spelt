defmodule SpeltWeb.R0.LoginController do
  use SpeltWeb, :controller

  @token_pattern ~r/^Bearer (.+)$/

  def show(conn, _params) do
    json(conn, %{flows: Enum.map(Spelt.Auth.login_types(), fn x -> %{type: x} end)})
  end

  def create(conn, params) do
    case Spelt.Auth.log_in(conn, params) do
      {:ok, body} ->
        conn
        |> put_status(200)
        |> json(body)

      {:error, :forbidden} ->
        conn
        |> put_status(403)
        |> json(%{errcode: "M_FORBIDDEN"})

      {:error, :bad_request} ->
        conn
        |> put_status(400)
        |> json(%{errcode: "M_UNKNOWN", error: "Unsupported or missing login type"})
    end
  end

  def delete(conn, _params) do
    with(
      [auth] <- Plug.Conn.get_req_header(conn, "authorization"),
      [_, token] <- Regex.run(@token_pattern, auth),
      :ok <- Spelt.Auth.log_out(token)
    ) do
      conn
      |> put_status(200)
      |> json(%{})
    else
      [] ->
        conn
        |> put_status(401)
        |> json(%{errcode: "M_MISSING_TOKEN"})

      :error ->
        conn
        |> put_status(401)
        |> json(%{errcode: "M_UNKNOWN_TOKEN"})
    end
  end

  def delete_all(conn, _params) do
    with(
      [auth] <- Plug.Conn.get_req_header(conn, "authorization"),
      [_, token] <- Regex.run(@token_pattern, auth),
      :ok <- Spelt.Auth.log_out_all(token)
    ) do
      conn
      |> put_status(200)
      |> json(%{})
    else
      [] ->
        conn
        |> put_status(401)
        |> json(%{errcode: "M_MISSING_TOKEN"})

      :error ->
        conn
        |> put_status(401)
        |> json(%{errcode: "M_UNKNOWN_TOKEN"})
    end
  end
end
