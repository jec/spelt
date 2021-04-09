defmodule Spelt.ConfigTest do
  use ExUnit.Case

  alias Spelt.Config

  describe "Config.versions/0" do
    test "returns supported client/server versions" do
      assert Config.versions() == ~w(r0.6.1)
    end
  end

  describe "Config.uri/0" do
    setup do
      previous_well_known = Application.get_env(:spelt, :well_known)
      on_exit(fn -> Application.put_env(:spelt, :well_known, previous_well_known) end)
    end

    test "returns an URI map of the homeserver from the :well_known config" do
      hostname = "chat.foobaz.net"
      port = 4000
      homeserver = "https://#{hostname}:#{port}/"

      Application.put_env(:spelt, :well_known, %{homeserver: homeserver})

      assert %{host: ^hostname, port: ^port} = Config.uri()
    end
  end

  describe "Config.hostname/0" do
    setup do
      previous_well_known = Application.get_env(:spelt, :well_known)
      on_exit(fn -> Application.put_env(:spelt, :well_known, previous_well_known) end)
    end

    test "returns the hostname of the homeserver from the :well_known config" do
      hostname = "chat.foobaz.net"
      port = 4000
      homeserver = "https://#{hostname}:#{port}/"

      Application.put_env(:spelt, :well_known, %{homeserver: homeserver})

      assert ^hostname = Config.hostname()
    end
  end
end
