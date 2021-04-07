defmodule Spelt.Auth.Authenticator do
  @moduledoc """
  A Plug that performs authentication using a provided JWT
  """

  import Plug.Conn
  require Logger

  alias Spelt.Auth
  alias Spelt.Auth.Token

  @token_pattern ~r/^Bearer (.+)$/

  def init(options) do
    options
  end

  def call(conn, _opts) do
    with(
      [auth] <- get_req_header(conn, "authorization"),
      [_, token] <- Regex.run(@token_pattern, auth),
      {:ok, %{"sub" => user_uuid, "jti" => jti}} <- Token.verify_and_validate(token),
      {user, session} <- Auth.get_user_and_session(user_uuid, jti)
    ) do
      conn
      |> assign(:spelt_user, user)
      |> assign(:spelt_session, session)
    else
      [] ->
        Logger.error("Authentication failed: missing or bad Authorization header")

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{errcode: "M_MISSING_TOKEN"}))
        |> halt()

      {:error, message} ->
        Logger.error("Authentication failed: JWT failed validation: #{message}")

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{errcode: "M_UNKNOWN_TOKEN"}))
        |> halt()

      {} ->
        Logger.error("Authentication failed: no matching User or Session found")

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{errcode: "M_UNKNOWN_TOKEN"}))
        |> halt()

      other ->
        Logger.error("Authentication failed: #{inspect(other)}")

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{errcode: "M_UNKNOWN_TOKEN"}))
        |> halt()
    end
  end
end
