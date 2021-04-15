defmodule SpeltWeb.R0.NotificationsController do
  use SpeltWeb, :controller

  def pushers_index(%{assigns: %{spelt_user: user}} = conn, _params) do
    pushers = Spelt.Notifications.get_pushers(user)
    json(conn, %{pushers: pushers})
  end

  def create_pusher(%{assigns: %{spelt_user: user}} = conn, params) do
    Spelt.Notifications.put_pusher(user, params)
    json(conn, %{})
  end
end
