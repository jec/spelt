defmodule Spelt.Auth.UserTest do
  use Spelt.Case
  import Seraph.Query

  alias Spelt.Auth.{Session, User}
  alias Spelt.Auth.Relationship.NoProperties.UserToSession.AuthenticatedAs

  describe "(User)-[AUTHENTICATED_AS]->(Session)" do
    test "with no related Sessions, returns an empty array" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))

      assert [] = match([
        {u, User, %{uuid: user.uuid}},
        {s, Session},
        [{u}, [r, AuthenticatedAs], {s}]
      ])
      |> return([s])
      |> Spelt.Repo.all()
    end

    test "with multiple related Sessions, returns an array of all" do
      {:ok, user} = Spelt.Repo.Node.create(build(:user))
      {:ok, session_1} = Spelt.Repo.Node.create(build(:session))
      {:ok, session_2} = Spelt.Repo.Node.create(build(:session))
      {:ok, _} = Spelt.Repo.Relationship.create(%AuthenticatedAs{start_node: user, end_node: session_1})
      {:ok, _} = Spelt.Repo.Relationship.create(%AuthenticatedAs{start_node: user, end_node: session_2})

      expected_jtis = MapSet.new([session_1.jti, session_2.jti])

      assert match([
                {u, User, %{uuid: user.uuid}},
                {s, Session},
                [{u}, [r, AuthenticatedAs], {s}]
              ])
              |> return([s])
              |> Spelt.Repo.all()
              |> Enum.map(fn m -> m["s"] end)
              |> Enum.map(fn s -> s.jti end)
              |> MapSet.new()
              |> MapSet.equal?(expected_jtis)
    end
  end
end
