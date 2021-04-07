defmodule Spelt.UserFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def user_factory(attrs) do
        identifier = Map.get(attrs, :identifier, Faker.Internet.user_name())
        password = Map.get(attrs, :password, UUID.uuid4())
        name = Map.get(attrs, :name, Faker.Person.name())
        email = Map.get(attrs, :email, Faker.Internet.email())

        %Spelt.Auth.User{
          identifier: identifier,
          name: name,
          email: email
        }
        |> Map.merge(Argon2.add_hash(password, hash_key: :encryptedPassword))
      end
    end
  end
end
