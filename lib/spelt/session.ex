defmodule Spelt.Session do
  @moduledoc """
  Implements actions related to logging in and logging out the user
  """

  def login_types, do: ~w(m.login.password)

  def log_in(
        %{
          "type" => "m.login.password",
          "password" => password,
          "identifier" => %{
            "type" => "m.id.user",
            "user" => username
          }
        } = params
      ) do
    # TODO: Use a proper implementation.
    if username == "@phred.smerd:localhost" and password == "foobarbaz" do
      # Use existing device_id or generate a new one.
      device_id = case params do
        %{"device_id" => id} -> id
        _ -> UUID.uuid4()
      end

      %{
        body: %{
          user_id: username,
          access_token: "foo",
          device_id: device_id
        },
        status: 200
      }
    else
      %{
        body: %{
          errcode: "M_FORBIDDEN"
        },
        status: 403
      }
    end
  end

  def log_in(_params) do
    %{
      body: %{
        errcode: "M_UNKNOWN",
        error: "Unsupported or missing login type"
      },
      status: 400
    }
  end
end
