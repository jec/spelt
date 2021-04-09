defmodule SpeltWeb.R0.LoginController do
  use SpeltWeb, :controller

  def show(conn, _params) do
    json(conn, %{flows: Enum.map(Spelt.Auth.login_types(), fn x -> %{type: x} end)})
  end

  def create(conn, params) do
    case Spelt.Auth.log_in(params) do
      {:ok, _, body} ->
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

  def delete(%{assigns: %{spelt_user: user, spelt_session: session}} = conn, _params) do
    :ok = Spelt.Auth.log_out(user, session)

    conn
    |> put_status(200)
    |> json(%{})
  end

  def delete_all(%{assigns: %{spelt_user: user}} = conn, _params) do
    :ok = Spelt.Auth.log_out_all(user)

    conn
    |> put_status(200)
    |> json(%{})
  end
end
