defmodule Spelt.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Spelt.Session.User{
          identifier: Faker.Internet.user_name(),
          password: UUID.uuid4(),
          name: Faker.Person.name(),
          email: Faker.Internet.email()
        }
      end
    end
  end
end
