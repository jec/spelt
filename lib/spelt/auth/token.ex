defmodule Spelt.Auth.Token do
  @moduledoc """
  Configures the generation and validation of JWTs
  """

  use Joken.Config, default_signer: :default

  @issuer "https://chat.spelt.io/"

  def token_config do
    default_claims(default_exp: 60 * 60, iss: @issuer, aud: @issuer) # expire in 1 hour
  end
end
