defmodule Spelt.Auth do
  @moduledoc """
  Implements actions related to logging in and logging out the user
  """

  import Seraph.Query
  require Logger

  alias Spelt.Matrix
  alias Spelt.Auth.User

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
      [identifier, ^hostname] -> do_log_in(identifier, hostname, password, params)
      [identifier, nil] -> do_log_in(identifier, hostname, password, params)
      _ ->
        Logger.info("Authentication failed for #{username}: not local")
        {:error, :forbidden}
    end
  end

  def log_in(_conn, _params) do
    {:error, :bad_request}
  end

  def log_out(nil) do
    Logger.info("No access token provided")
    {:error, :bad_request}
  end

  def log_out(_access_token) do
    :ok
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
      {:ok, _} ->
        # Use existing device_id or generate a new one.
        device_id = case params do
          %{"device_id" => id} -> id
          _ -> UUID.uuid4()
        end

        {:ok,
          %{
            user_id: Matrix.user_to_fq_user_id(%{host: hostname}, username),
            access_token: "foo",
            device_id: device_id
          },
        }
      {:error, message} ->
        Logger.info("Authentication failed for #{username}: #{message}")
        {:error, :forbidden}
    end
  end
end
