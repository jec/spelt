defmodule Spelt.Case do
  @moduledoc """
  Provides common setup and teardown for all tests
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Spelt.Factory
    end
  end

  setup _tags do
    # Delete all nodes from the database after each test.
    on_exit(fn -> {:ok, _} = Bolt.Sips.conn() |> Bolt.Sips.query("MATCH (x) DETACH DELETE x") end)

    :ok
  end
end
