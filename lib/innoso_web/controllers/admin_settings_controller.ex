defmodule InnosoWeb.AdminSettingsController do
  use InnosoWeb, :controller

  alias Innoso.Accounts
  alias InnosoWeb.AdminAuth

  import InnosoWeb.AdminAuth, only: [require_sudo_mode: 2]

  plug :require_sudo_mode
  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, :edit)
  end

  def update(conn, %{"action" => "update_email"} = params) do
    %{"admin" => admin_params} = params
    admin = conn.assigns.current_scope.admin

    case Accounts.change_admin_email(admin, admin_params) do
      %{valid?: true} = changeset ->
        Accounts.deliver_admin_update_email_instructions(
          Ecto.Changeset.apply_action!(changeset, :insert),
          admin.email,
          &url(~p"/admin/settings/confirm-email/#{&1}")
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your email change has been sent to the new address."
        )
        |> redirect(to: ~p"/admin/settings")

      changeset ->
        render(conn, :edit, email_changeset: %{changeset | action: :insert})
    end
  end

  def update(conn, %{"action" => "update_password"} = params) do
    %{"admin" => admin_params} = params
    admin = conn.assigns.current_scope.admin

    case Accounts.update_admin_password(admin, admin_params) do
      {:ok, {admin, _}} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:admin_return_to, ~p"/admin/settings")
        |> AdminAuth.log_in_admin(admin)

      {:error, changeset} ->
        render(conn, :edit, password_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_admin_email(conn.assigns.current_scope.admin, token) do
      {:ok, _admin} ->
        conn
        |> put_flash(:info, "Email changed successfully.")
        |> redirect(to: ~p"/admin/settings")

      {:error, _} ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: ~p"/admin/settings")
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    admin = conn.assigns.current_scope.admin

    conn
    |> assign(:email_changeset, Accounts.change_admin_email(admin))
    |> assign(:password_changeset, Accounts.change_admin_password(admin))
  end
end
