defmodule InnosoWeb.AdminRegistrationController do
  use InnosoWeb, :controller

  alias Innoso.Accounts
  alias Innoso.Accounts.Admin

  def new(conn, _params) do
    changeset = Accounts.change_admin_email(%Admin{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"admin" => admin_params}) do
    case Accounts.register_admin(admin_params) do
      {:ok, admin} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            admin,
            &url(~p"/admin/login/#{&1}")
          )

        conn
        |> put_flash(
          :info,
          "An email was sent to #{admin.email}, please access it to confirm your account."
        )
        |> redirect(to: ~p"/admin/login")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end
end
