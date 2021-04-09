defmodule Spelt.Config do
  @moduledoc """
  Implements actions related to the basic configuration of Spelt
  """

  def versions, do: ~w(r0.6.1)

  def hostname do
    uri() |> Map.get(:host)
  end

  def uri do
    Application.get_env(:spelt, :well_known)
    |> Map.get(:homeserver)
    |> URI.parse()
  end
end
