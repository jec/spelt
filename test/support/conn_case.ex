defmodule SpeltWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use SpeltWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import SpeltWeb.ConnCase

      alias SpeltWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint SpeltWeb.Endpoint
    end
  end

  setup _tags do
    # TODO: Put this in a place that is shared with Spelt.Case.
    # Delete all nodes from the database after each test.
    on_exit(fn -> {:ok, _} = Bolt.Sips.conn() |> Bolt.Sips.query("MATCH (x) DETACH DELETE x") end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
