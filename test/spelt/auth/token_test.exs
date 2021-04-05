defmodule Spelt.Auth.TokenTest do
  use Spelt.Case

  alias Spelt.Auth.Token

  describe "Token.generate_and_sign" do
    test "returns a valid JWT" do
      user_uuid = UUID.uuid4()

      assert {:ok, token, %{"sub" => ^user_uuid}} = Token.generate_and_sign(%{"sub" => user_uuid})
      assert {:ok, %{"sub" => ^user_uuid}} = Token.verify_and_validate(token)
    end
  end
end
