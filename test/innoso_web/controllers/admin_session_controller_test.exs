defmodule InnosoWeb.AdminSessionControllerTest do
  use InnosoWeb.ConnCase

  import Innoso.AccountsFixtures
  alias Innoso.Accounts

  setup do
    %{admin: admin_fixture()}
  end

  describe "GET /admin/login" do
    test "renders login page", %{conn: conn} do
      conn = get(conn, ~p"/admin/login")
      response = html_response(conn, 200)
      assert response =~ "Sign in"
      assert response =~ ~p"/admin/login"
    end

    test "redirects to admin panel if already logged in", %{conn: conn, admin: admin} do
      conn = conn |> log_in_admin(admin) |> get(~p"/admin/login")
      assert redirected_to(conn) == ~p"/admin"
    end
  end

  describe "GET /admin/login/:token" do
    test "renders confirmation page for confirmed admin", %{conn: conn, admin: admin} do
      token =
        extract_admin_token(fn url ->
          Accounts.deliver_login_instructions(admin, url)
        end)

      conn = get(conn, ~p"/admin/login/#{token}")
      html = html_response(conn, 200)
      assert html =~ "Keep me logged in on this device"
    end

    test "raises error for invalid token", %{conn: conn} do
      conn = get(conn, ~p"/admin/login/invalid-token")
      assert redirected_to(conn) == ~p"/admin/login"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "Magic link is invalid or it has expired."
    end
  end

  describe "POST /admin/login - email and password" do
    test "logs the admin in", %{conn: conn, admin: admin} do
      admin = set_password(admin)

      conn =
        post(conn, ~p"/admin/login", %{
          "admin" => %{"email" => admin.email, "password" => valid_admin_password()}
        })

      assert get_session(conn, :admin_token)
      assert redirected_to(conn) == ~p"/admin"
    end

    test "logs the admin in with remember me", %{conn: conn, admin: admin} do
      admin = set_password(admin)

      conn =
        post(conn, ~p"/admin/login", %{
          "admin" => %{
            "email" => admin.email,
            "password" => valid_admin_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_innoso_web_admin_remember_me"]
      assert redirected_to(conn) == ~p"/admin"
    end

    test "logs the admin in with return to", %{conn: conn, admin: admin} do
      admin = set_password(admin)

      conn =
        conn
        |> init_test_session(admin_return_to: "/foo/bar")
        |> post(~p"/admin/login", %{
          "admin" => %{
            "email" => admin.email,
            "password" => valid_admin_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "emits error message with invalid credentials", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/admin/login", %{
          "admin" => %{"email" => admin.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "Sign in"
      assert response =~ "Invalid email or password"
    end
  end

  describe "POST /admin/login - magic link" do
    test "sends magic link email when admin exists", %{conn: conn, admin: admin} do
      conn =
        post(conn, ~p"/admin/login", %{
          "admin" => %{"email" => admin.email}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Innoso.Repo.get_by!(Accounts.AdminToken, admin_id: admin.id).context == "login"
    end

    test "logs the admin in", %{conn: conn, admin: admin} do
      {token, _hashed_token} = generate_admin_magic_link_token(admin)

      conn =
        post(conn, ~p"/admin/login", %{
          "admin" => %{"token" => token}
        })

      assert get_session(conn, :admin_token)
      assert redirected_to(conn) == ~p"/admin"
    end

    test "emits error message when magic link is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/admin/login", %{
          "admin" => %{"token" => "invalid"}
        })

      assert html_response(conn, 200) =~ "The link is invalid or it has expired."
    end
  end

  describe "DELETE /admin/logout" do
    test "logs the admin out", %{conn: conn, admin: admin} do
      conn = conn |> log_in_admin(admin) |> delete(~p"/admin/logout")
      assert redirected_to(conn) == ~p"/admin/login"
      refute get_session(conn, :admin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the admin is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/admin/logout")
      assert redirected_to(conn) == ~p"/admin/login"
      refute get_session(conn, :admin_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
