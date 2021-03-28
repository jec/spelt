defmodule Spelt.SessionTest do
  use ExUnit.Case

  alias Spelt.Session

  describe "Session.login_types/0" do
    test "returns supported login types" do
      assert Session.login_types() == ~w(m.login.password)
    end
  end

  describe "Session.log_in/1" do
    test "with valid credentials, returns status 200" do
      user_id = "@phred.smerd:localhost"
      password = "foobarbaz"
      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => user_id
        },
        "password" => password,
        "initial_device_display_name" => "My Device"
      }

      assert %{
        body: %{
          user_id: ^user_id,
          access_token: _,
          device_id: _
        },
        status: 200
      } = Session.log_in(params)
    end

    test "with valid credentials and a device_id, returns status 200" do
      user_id = "@phred.smerd:localhost"
      password = "foobarbaz"
      device_id = "mydeviceid"

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => user_id
        },
        "password" => password,
        "device_id" => device_id,
        "initial_device_display_name" => "My Device"
      }

      assert %{
               body: %{
                 user_id: ^user_id,
                 access_token: _,
                 device_id: ^device_id
               },
               status: 200
             } = Session.log_in(params)
    end

    test "with invalid credentials, returns status 403" do
      user_id = "@phred.smerd:localhost"
      password = "bad-password"

      params = %{
        "type" => "m.login.password",
        "identifier" => %{
          "type" => "m.id.user",
          "user" => user_id
        },
        "password" => password,
        "initial_device_display_name" => "My Device"
      }

      assert %{
               body: %{
                 errcode: "M_FORBIDDEN"
               },
               status: 403
             } = Session.log_in(params)
    end

    test "with no `type`, returns status 400" do
      assert %{
               body: %{
                 errcode: "M_UNKNOWN"
               },
               status: 400
             } = Session.log_in(%{})
    end
  end
end
