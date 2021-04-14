defmodule Spelt.Factory do
  @moduledoc false

  use ExMachina
  use Spelt.PusherFactory
  use Spelt.SessionFactory
  use Spelt.UserFactory
end
