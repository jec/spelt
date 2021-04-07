defmodule Spelt.Auth do
  @moduledoc """
  Implements actions related to logging in and logging out the user
  """

  import Seraph.Query
  require Logger

  alias Spelt.Matrix
  alias Spelt.Auth.{Session, Token, User}
  alias Spelt.Auth.Relationship.NoProperties.UserToSession.AuthenticatedAs

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
      [identifier, ^hostname] ->
        do_log_in(identifier, hostname, password, params)

      [identifier, nil] ->
        do_log_in(identifier, hostname, password, params)

      _ ->
        Logger.info("Authentication failed for #{username}: not local")
        {:error, :forbidden}
    end
  end

  def log_in(_conn, _params) do
    {:error, :bad_request}
  end

  def log_out(user, session) do
    Spelt.Repo.Node.delete(session)
    Logger.info("Logged out user #{user.identifier}")
    :ok
  end

  def log_out_all(user) do
    {:ok, %{stats: %{"nodes-deleted" => count}}} =
      match([
        {u, User, %{uuid: user.uuid}},
        {s, Session},
        [{u}, [r, AuthenticatedAs], {s}]
      ])
      |> delete([s])
      |> Spelt.Repo.execute(with_stats: true)

    Logger.info("Logged out user #{user.identifier} from #{count} sessions")
    :ok
  end

  def create_session(user, hostname, device_id \\ nil) do
    # Use existing device_id or generate a new one.
    device_id = device_id || UUID.uuid4()

    # Create a Token, a Session and its relationship from User.
    {:ok, token, %{"jti" => jti, "exp" => exp}} = Token.generate_and_sign(%{"sub" => user.uuid})

    {:ok, session} =
      Spelt.Repo.Node.create(%Session{jti: jti, expiresAt: DateTime.from_unix!(exp)})

    {:ok, _} =
      Spelt.Repo.Relationship.create(%AuthenticatedAs{start_node: user, end_node: session})

    {:ok, session,
     %{
       user_id: Matrix.user_to_fq_user_id(%{host: hostname}, user.identifier),
       access_token: token,
       device_id: device_id
     }}
  end

  def get_user_and_session(user_uuid, jti) do
    case match([
           {u, User, %{uuid: user_uuid}},
           {s, Session, %{jti: jti}},
           [{u}, [r, AuthenticatedAs], {s}]
         ])
         |> return([u, s])
         |> Spelt.Repo.one() do
      nil -> {}
      %{"u" => user, "s" => session} -> {user, session}
    end
  end

  defp do_log_in(username, hostname, password, params) do
    match([{u, User}])
    |> where(u.identifier == ^username)
    |> return([u])
    |> Spelt.Repo.one()
    |> check_password(username, hostname, password, params)
  end

  defp check_password(nil, username, _hostname, _password, _params) do
    Logger.info("Authentication failed for #{username}: unknown user")
    {:error, :forbidden}
  end

  defp check_password(%{} = record, username, hostname, password, params) do
    case record
         |> Map.get("u")
         |> Argon2.check_pass(password, hash_key: :encryptedPassword) do
      {:ok, user} ->
        create_session(user, hostname, params["device_id"])

      {:error, message} ->
        Logger.info("Authentication failed for #{username}: #{message}")
        {:error, :forbidden}
    end
  end
end
