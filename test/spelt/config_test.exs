defmodule Spelt.ConfigTest do
  use ExUnit.Case

  alias Spelt.Config

  describe "Config.versions/0" do
    test "returns supported client/server versions" do
      assert Config.versions() == ~w(r0.6.1)
    end
  end
end
