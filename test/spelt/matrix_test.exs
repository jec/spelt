defmodule Spelt.MatrixTest do
  use ExUnit.Case

  alias Spelt.Matrix

  describe "Matrix.split_user_id/1" do
    test "with invalid user name, returns nil" do
      assert Matrix.split_user_id("!") == nil
      assert Matrix.split_user_id("@") == nil
      assert Matrix.split_user_id(":") == nil
    end

    test "with local user name part, returns the local user name part" do
      assert ["phred", nil] = Matrix.split_user_id("phred")
      assert ["phred", nil] = Matrix.split_user_id("@phred")
    end

    test "with fully qualified user name, returns the user and hostname parts" do
      assert ["phred.smerd", "example.net"] = Matrix.split_user_id("@phred.smerd:example.net")
    end
  end

  describe "Matrix.user_to_fq_user_id/2" do
    test "returns the fully qualified user ID" do
      conn = %{host: "foobar.net"}
      assert Matrix.user_to_fq_user_id(conn, "phred.smerd") == "@phred.smerd:foobar.net"

      assert Matrix.user_to_fq_user_id(conn, "@phred.smerd:example.cc") ==
               "@phred.smerd:example.cc"
    end
  end
end
