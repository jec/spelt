defmodule Spelt.Session.User do
  @moduledoc """
  Represents a user
  """

  defstruct [:identifier, :password, :name, :email]
end
