defmodule Spelt.Auth.AuthenticatorTest do
  use Spelt.Case
  use Plug.Test

  alias Spelt.Auth
  alias Spelt.Auth.{Authenticator, Token}

  @opts Authenticator.init([])

  test "with a valid token, adds the authentication info to the connection" do
    {:ok, user} = Spelt.Repo.Node.create(build(:user))

    {:ok,
     %{
       user_id: _,
       access_token: token,
       device_id: _
     }} = Auth.create_session(user, "talk.example.cc")

    assert %Plug.Conn{assigns: %{spelt_user: _user, spelt_session: _session}} =
             conn(:get, "/foo")
             |> put_req_header("authorization", "Bearer #{token}")
             |> Authenticator.call(@opts)

    # TODO: Assert the user and session from the connection.
  end

  test "with an unknown token, halts the Plug chain with a 401" do
    {:ok, token, _claims} = Token.generate_and_sign(%{"sub" => "foo"})
    expected_body = Jason.encode!(%{errcode: "M_UNKNOWN_TOKEN"})

    assert %Plug.Conn{halted: true, status: 401, resp_body: ^expected_body} =
             conn(:get, "/foo")
             |> put_req_header("authorization", "Bearer #{token}")
             |> Authenticator.call(@opts)
  end

  test "with an invalid token, halts the Plug chain with a 401" do
    {:ok, token, _claims} = Token.generate_and_sign(%{"sub" => "foo"})
    expected_body = Jason.encode!(%{errcode: "M_UNKNOWN_TOKEN"})

    assert %Plug.Conn{halted: true, status: 401, resp_body: ^expected_body} =
             conn(:get, "/foo")
             |> put_req_header("authorization", "Bearer #{token}x")
             |> Authenticator.call(@opts)
  end

  test "with no token, halts the Plug chain with a 401" do
    expected_body = Jason.encode!(%{errcode: "M_MISSING_TOKEN"})

    assert %Plug.Conn{halted: true, status: 401, resp_body: ^expected_body} =
             conn(:get, "/foo")
             |> Authenticator.call(@opts)
  end
end
