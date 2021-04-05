defmodule Spelt.SessionFactory do
  defmacro __using__(_opts) do
    quote do
      def session_factory(attrs) do
        jti = Map.get(attrs, :jti, Joken.generate_jti())
        expires_at = Map.get(attrs, :expiresAt, DateTime.utc_now |> DateTime.add(30 * 60, :second))

        %Spelt.Auth.Session{
          jti: jti,
          expiresAt: expires_at
        }
      end
    end
  end
end
