defmodule Spelt.PusherFactory do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def pusher_factory(attrs) do
        push_key = Map.get(attrs, :push_key, UUID.uuid4())
        kind = Map.get(attrs, :kind, "email")
        app_id = Map.get(attrs, :app_id, "m.email")
        app_display_name = Map.get(attrs, :app_display_name, "My Matrix App")
        device_display_name = Map.get(attrs, :device_display_name, "Mobile")
        profile_tag = Map.get(attrs, :profile_tag, nil)
        lang = Map.get(attrs, :lang, "en")
        data = Map.get(attrs, :data, %{}) |> Jason.encode!()

        %Spelt.Notifications.Pusher{
          pushKey: push_key,
          kind: kind,
          appId: app_id,
          appDisplayName: app_display_name,
          deviceDisplayName: device_display_name,
          profileTag: profile_tag,
          lang: lang,
          data: data
        }
      end
    end
  end
end
