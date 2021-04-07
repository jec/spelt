defmodule SpeltWeb.Router do
  use SpeltWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # This one may not need to be implemented here but instead handled by the
  # proxy.
  # scope "/.well-known/matrix", SpeltWeb do
  #   pipe_through :api
  #
  #   get "/client", ConfigController, :client
  # end

  scope "/_matrix/client", SpeltWeb do
    pipe_through :api

    get "/versions", ConfigController, :versions

    scope "/r0", R0 do
      get "/login", LoginController, :show
      post "/login", LoginController, :create
      post "/logout", LoginController, :delete
      post "/logout/all", LoginController, :delete_all
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
