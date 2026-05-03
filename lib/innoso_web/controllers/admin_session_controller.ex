defmodule InnosoWeb.AdminSessionController do
  use InnosoWeb, :controller

  alias Innoso.Accounts
  alias InnosoWeb.AdminAuth

  def new(conn, _params) do
    email = get_in(conn.assigns, [:current_scope, Access.key(:admin), Access.key(:email)])
    form = Phoenix.Component.to_form(%{"email" => email}, as: "admin")

    render(conn, :new, form: form)
  end

  # magic link login
  def create(conn, %{"admin" => %{"token" => token} = admin_params} = params) do
    info =
      case params do
        %{"_action" => "confirmed"} -> "Admin confirmed successfully."
        _ -> "Welcome back!"
      end

    case Accounts.login_admin_by_magic_link(token) do
      {:ok, {admin, _expired_tokens}} ->
        conn
        |> put_flash(:info, info)
        |> AdminAuth.log_in_admin(admin, admin_params)

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "The link is invalid or it has expired.")
        |> render(:new, form: Phoenix.Component.to_form(%{}, as: "admin"))
    end
  end

  # email + password login
  def create(conn, %{"admin" => %{"email" => email, "password" => password} = admin_params}) do
    if admin = Accounts.get_admin_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Welcome back!")
      |> AdminAuth.log_in_admin(admin, admin_params)
    else
      form = Phoenix.Component.to_form(admin_params, as: "admin")

      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> render(:new, form: form)
    end
  end

  # magic link request
  def create(conn, %{"admin" => %{"email" => email}}) do
    if admin = Accounts.get_admin_by_email(email) do
      Accounts.deliver_login_instructions(
        admin,
        &url(~p"/admin/login/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions for logging in shortly."

    conn
    |> put_flash(:info, info)
    |> redirect(to: ~p"/admin/login")
  end

  def confirm(conn, %{"token" => token}) do
    if admin = Accounts.get_admin_by_magic_link_token(token) do
      form = Phoenix.Component.to_form(%{"token" => token}, as: "admin")

      conn
      |> assign(:admin, admin)
      |> assign(:form, form)
      |> render(:confirm)
    else
      conn
      |> put_flash(:error, "Magic link is invalid or it has expired.")
      |> redirect(to: ~p"/admin/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> AdminAuth.log_out_admin()
  end
end
