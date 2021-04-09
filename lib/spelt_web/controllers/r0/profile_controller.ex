defmodule SpeltWeb.R0.ProfileController do
  use SpeltWeb, :controller

  alias Spelt.Profile

  def show_display_name(conn, %{"user_id" => user_id}) do
    case Profile.get_display_name(user_id) do
      nil -> conn |> put_status(404) |> json(%{})
      name -> json(conn, %{displayname: name})
    end
  end

  def update_display_name(%{assigns: %{spelt_user: user}} = conn, %{
        "user_id" => user_id,
        "displayname" => display_name
      }) do
    case Profile.set_display_name(user, user_id, display_name) do
      :ok -> json(conn, %{})
      :error -> conn |> put_status(403) |> json(%{errcode: "M_FORBIDDEN"})
    end
  end
end
