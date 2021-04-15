defmodule SpeltWeb.NotificationsControllerTest do
  use SpeltWeb.ConnCase

  alias Spelt.{Auth, Config}
  alias Spelt.Notifications.Relationship.NoProperties.UserToPusher.NotifiedBy

  describe "GET /_matrix/client/r0/pushers" do
    test "with valid credentials, returns Pushers related to the User", %{conn: conn} do
      {:ok, user} = build(:user) |> Spelt.Repo.Node.create()
      {:ok, _, %{access_token: token}} = Auth.create_session(user, Config.hostname())

      {:ok,
       %{
         pushKey: push_key,
         kind: kind,
         appId: app_id,
         appDisplayName: app_display_name,
         deviceDisplayName: device_display_name,
         profileTag: profile_tag,
         lang: lang,
         data: data
       } = pusher} = build(:pusher) |> Spelt.Repo.Node.create()

      {:ok, _} = Spelt.Repo.Relationship.create(%NotifiedBy{start_node: user, end_node: pusher})

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(Routes.notifications_path(conn, :pushers_index))

      assert %{
               "pushers" => [
                 %{
                   "pushkey" => ^push_key,
                   "kind" => ^kind,
                   "app_id" => ^app_id,
                   "app_display_name" => ^app_display_name,
                   "device_display_name" => ^device_display_name,
                   "profile_tag" => ^profile_tag,
                   "lang" => ^lang,
                   "data" => ^data
                 }
               ]
             } = json_response(response, 200)
    end
  end

  describe "POST /_matrix/client/r0/pushers/set" do
    test "with valid credentials, creates a Pusher related to the User", %{conn: conn} do
      {:ok, user} = build(:user) |> Spelt.Repo.Node.create()
      {:ok, _, %{access_token: token}} = Auth.create_session(user, Config.hostname())
      push_key = UUID.uuid4()
      app_id = UUID.uuid4()
      profile_tag = "foobar"
      app_display_name = "Phred Smerd"

      params = %{
        lang: "en",
        kind: "http",
        app_display_name: app_display_name,
        device_display_name: "Mobile",
        profile_tag: profile_tag,
        app_id: app_id,
        pushkey: push_key,
        data: %{
          url: "https://push-gateway.location.here/_matrix/push/v1/notify",
          format: "event_id_only"
        },
        append: false
      }

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.notifications_path(conn, :create_pusher), params)

      assert json_response(response, 200) == %{}

      assert [
               %{
                 lang: "en",
                 kind: "http",
                 appDisplayName: ^app_display_name,
                 deviceDisplayName: "Mobile",
                 pushKey: ^push_key,
                 appId: ^app_id,
                 profileTag: ^profile_tag
               }
             ] = Spelt.Notifications.get_pushers(user)
    end
  end
end
