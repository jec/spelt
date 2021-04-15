defmodule SpeltWeb.Router do
  use SpeltWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authentication do
    plug Spelt.Auth.Authenticator
  end

  scope "/.well-known", SpeltWeb do
    pipe_through :api

    get "/matrix/client", ConfigController, :well_known
  end

  scope "/_matrix/client", SpeltWeb do
    pipe_through :api

    get "/versions", ConfigController, :versions

    # no authentication required
    scope "/r0", R0 do
      get "/login", LoginController, :show
      post "/login", LoginController, :create

      get "/profile/:user_id/displayname", ProfileController, :show_display_name
    end

    # authentication required
    scope "/r0", R0 do
      pipe_through :authentication

      post "/logout", LoginController, :delete
      post "/logout/all", LoginController, :delete_all

      put "/profile/:user_id/displayname", ProfileController, :update_display_name

      get "/thirdparty/protocols", ThirdPartyController, :protocol_index

      get "/pushers", NotificationsController, :pushers_index
      post "/pushers/set", NotificationsController, :create_pusher
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: SpeltWeb.Telemetry
    end
  end
end
