defmodule Spelt.Matrix do
  @moduledoc """
  Implements utility functions related to Matrix
  """

  @fq_pattern ~r{^(@?)([-a-z0-9._=/]+)(:([-a-zA-Z0-9.]+))?$}

  def user_to_fq_user_id(username) do
    hostname = Spelt.Config.hostname()

    case split_user_id(username) do
      [user, nil] -> "@#{user}:#{hostname}"
      [_user, _host] -> username
      nil -> nil
    end
  end

  def split_user_id(username) do
    case Regex.run(@fq_pattern, username) do
      [_, _, user, _, host] -> [user, host]
      [_, _, user] -> [user, nil]
      _ -> nil
    end
  end
end
