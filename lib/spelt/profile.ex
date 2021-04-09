defmodule Spelt.Profile do
  @moduledoc """
  Implements actions related to User profiles
  """

  alias Spelt.Auth.User

  def get_display_name(user_id) do
    hostname = Spelt.Config.hostname()

    with(
      [identifier, ^hostname] <- Spelt.Matrix.split_user_id(user_id),
      user when not is_nil(user) <- Spelt.Repo.Node.get_by(User, identifier: identifier)
    ) do
      user.displayName
    end
  end

  @doc "Verifies that `user_id` refers to the authenticated `user` and updates its display name"
  def set_display_name(user, user_id, display_name) do
    identifier = user.identifier
    hostname = Spelt.Config.hostname()

    with(
      [^identifier, ^hostname] <- Spelt.Matrix.split_user_id(user_id),
      {:ok, _} <- user |> User.changeset(%{displayName: display_name}) |> Spelt.Repo.Node.set()
    ) do
      :ok
    else
      _ -> :error
    end
  end
end
