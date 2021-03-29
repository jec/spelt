defmodule Spelt.Session do
  @moduledoc """
  Implements actions related to logging in and logging out the user
  """

  require Logger

  alias Spelt.Matrix
  alias Bolt.Sips, as: Bolt

  @response_400 %{
    body: %{
      errcode: "M_UNKNOWN",
      error: "Unsupported or missing login type"
    },
    status: 400
  }

  @response_403 %{
    body: %{
      errcode: "M_FORBIDDEN"
    },
    status: 403
  }

  def login_types, do: ~w(m.login.password)

  def log_in(
        %{host: hostname},
        %{
          "type" => "m.login.password",
          "password" => password,
          "identifier" => %{
            "type" => "m.id.user",
            "user" => username
          }
        } = params
      ) do
    Logger.info("Authenticating user #{username}")
    case Matrix.split_user_id(username) do
      [user, ^hostname] -> _log_in(hostname, user, password, params)
      [user, nil] -> _log_in(hostname, user, password, params)
      _ ->
        Logger.info("Authentication failed for #{username}: not local")
        @response_403
    end
  end

  def log_in(_conn, _params) do
    @response_400
  end

  defp _log_in(hostname, username, password, params) do
    cypher = """
      MATCH (user:User {user_id: '#{username}', password: '#{password}'})
      RETURN user
    """
    response = Bolt.conn() |> Bolt.query!(cypher) |> Bolt.Response.first()

    if response do
      # Use existing device_id or generate a new one.
      device_id = case params do
        %{"device_id" => id} -> id
        _ -> UUID.uuid4()
      end

      %{
        body: %{
          user_id: Matrix.user_to_fq_user_id(%{host: hostname}, username),
          access_token: "foo",
          device_id: device_id
        },
        status: 200
      }
    else
      Logger.info("Authentication failed for #{username}: user not found")
      @response_403
    end
  end
end
