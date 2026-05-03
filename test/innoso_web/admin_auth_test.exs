defmodule InnosoWeb.AdminAuthTest do
  use InnosoWeb.ConnCase

  alias Innoso.Accounts
  alias Innoso.Accounts.Scope
  alias InnosoWeb.AdminAuth

  import Innoso.AccountsFixtures

  @remember_me_cookie "_innoso_web_admin_remember_me"
  @remember_me_cookie_max_age 60 * 60 * 24 * 14

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, InnosoWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{admin: %{admin_fixture() | authenticated_at: DateTime.utc_now(:second)}, conn: conn}
  end

  describe "log_in_admin/3" do
    test "stores the admin token in the session", %{conn: conn, admin: admin} do
      conn = AdminAuth.log_in_admin(conn, admin)
      assert token = get_session(conn, :admin_token)
      assert redirected_to(conn) == ~p"/admin"
      assert Accounts.get_admin_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, admin: admin} do
      conn = conn |> put_session(:to_be_removed, "value") |> AdminAuth.log_in_admin(admin)
      refute get_session(conn, :to_be_removed)
    end

    test "keeps session when re-authenticating", %{conn: conn, admin: admin} do
      conn =
        conn
        |> assign(:current_scope, Scope.for_admin(admin))
        |> put_session(:to_be_removed, "value")
        |> AdminAuth.log_in_admin(admin)

      assert get_session(conn, :to_be_removed)
    end

    test "clears session when admin does not match when re-authenticating", %{
      conn: conn,
      admin: admin
    } do
      other_admin = admin_fixture()

      conn =
        conn
        |> assign(:current_scope, Scope.for_admin(other_admin))
        |> put_session(:to_be_removed, "value")
        |> AdminAuth.log_in_admin(admin)

      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, admin: admin} do
      conn = conn |> put_session(:admin_return_to, "/hello") |> AdminAuth.log_in_admin(admin)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, admin: admin} do
      conn = conn |> fetch_cookies() |> AdminAuth.log_in_admin(admin, %{"remember_me" => "true"})
      assert get_session(conn, :admin_token) == conn.cookies[@remember_me_cookie]
      assert get_session(conn, :admin_remember_me) == true

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :admin_token)
      assert max_age == @remember_me_cookie_max_age
    end

    test "writes a cookie if remember_me was set in previous session", %{conn: conn, admin: admin} do
      conn = conn |> fetch_cookies() |> AdminAuth.log_in_admin(admin, %{"remember_me" => "true"})
      assert get_session(conn, :admin_token) == conn.cookies[@remember_me_cookie]
      assert get_session(conn, :admin_remember_me) == true

      conn =
        conn
        |> recycle()
        |> Map.replace!(:secret_key_base, InnosoWeb.Endpoint.config(:secret_key_base))
        |> fetch_cookies()
        |> init_test_session(%{admin_remember_me: true})

      # the conn is already logged in and has the remember_me cookie set,
      # now we log in again and even without explicitly setting remember_me,
      # the cookie should be set again
      conn = conn |> AdminAuth.log_in_admin(admin, %{})
      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :admin_token)
      assert max_age == @remember_me_cookie_max_age
      assert get_session(conn, :admin_remember_me) == true
    end
  end

  describe "logout_admin/1" do
    test "erases session and cookies", %{conn: conn, admin: admin} do
      admin_token = Accounts.generate_admin_session_token(admin)

      conn =
        conn
        |> put_session(:admin_token, admin_token)
        |> put_req_cookie(@remember_me_cookie, admin_token)
        |> fetch_cookies()
        |> AdminAuth.log_out_admin()

      refute get_session(conn, :admin_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/admin/login"
      refute Accounts.get_admin_by_session_token(admin_token)
    end

    test "works even if admin is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> AdminAuth.log_out_admin()
      refute get_session(conn, :admin_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == ~p"/admin/login"
    end
  end

  describe "fetch_current_scope_for_admin/2" do
    test "authenticates admin from session", %{conn: conn, admin: admin} do
      admin_token = Accounts.generate_admin_session_token(admin)

      conn =
        conn |> put_session(:admin_token, admin_token) |> AdminAuth.fetch_current_scope_for_admin([])

      assert conn.assigns.current_scope.admin.id == admin.id
      assert conn.assigns.current_scope.admin.authenticated_at == admin.authenticated_at
      assert get_session(conn, :admin_token) == admin_token
    end

    test "authenticates admin from cookies", %{conn: conn, admin: admin} do
      logged_in_conn =
        conn |> fetch_cookies() |> AdminAuth.log_in_admin(admin, %{"remember_me" => "true"})

      admin_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> AdminAuth.fetch_current_scope_for_admin([])

      assert conn.assigns.current_scope.admin.id == admin.id
      assert conn.assigns.current_scope.admin.authenticated_at == admin.authenticated_at
      assert get_session(conn, :admin_token) == admin_token
      assert get_session(conn, :admin_remember_me)
    end

    test "does not authenticate if data is missing", %{conn: conn, admin: admin} do
      _ = Accounts.generate_admin_session_token(admin)
      conn = AdminAuth.fetch_current_scope_for_admin(conn, [])
      refute get_session(conn, :admin_token)
      refute conn.assigns.current_scope
    end

    test "reissues a new token after a few days and refreshes cookie", %{conn: conn, admin: admin} do
      logged_in_conn =
        conn |> fetch_cookies() |> AdminAuth.log_in_admin(admin, %{"remember_me" => "true"})

      token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      offset_admin_token(token, -10, :day)
      {admin, _} = Accounts.get_admin_by_session_token(token)

      conn =
        conn
        |> put_session(:admin_token, token)
        |> put_session(:admin_remember_me, true)
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> AdminAuth.fetch_current_scope_for_admin([])

      assert conn.assigns.current_scope.admin.id == admin.id
      assert conn.assigns.current_scope.admin.authenticated_at == admin.authenticated_at
      assert new_token = get_session(conn, :admin_token)
      assert new_token != token
      assert %{value: new_signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert new_signed_token != signed_token
      assert max_age == @remember_me_cookie_max_age
    end
  end

  describe "require_sudo_mode/2" do
    test "allows admins that have authenticated in the last 10 minutes", %{conn: conn, admin: admin} do
      conn =
        conn
        |> fetch_flash()
        |> assign(:current_scope, Scope.for_admin(admin))
        |> AdminAuth.require_sudo_mode([])

      refute conn.halted
      refute conn.status
    end

    test "redirects when authentication is too old", %{conn: conn, admin: admin} do
      eleven_minutes_ago = DateTime.utc_now(:second) |> DateTime.add(-11, :minute)
      admin = %{admin | authenticated_at: eleven_minutes_ago}
      admin_token = Accounts.generate_admin_session_token(admin)
      {admin, token_inserted_at} = Accounts.get_admin_by_session_token(admin_token)
      assert DateTime.compare(token_inserted_at, admin.authenticated_at) == :gt

      conn =
        conn
        |> fetch_flash()
        |> assign(:current_scope, Scope.for_admin(admin))
        |> AdminAuth.require_sudo_mode([])

      assert redirected_to(conn) == ~p"/admin/login"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must re-authenticate to access this page."
    end
  end

  describe "redirect_if_admin_is_authenticated/2" do
    setup %{conn: conn} do
      %{conn: AdminAuth.fetch_current_scope_for_admin(conn, [])}
    end

    test "redirects if admin is authenticated", %{conn: conn, admin: admin} do
      conn =
        conn
        |> assign(:current_scope, Scope.for_admin(admin))
        |> AdminAuth.redirect_if_admin_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == ~p"/admin"
    end

    test "does not redirect if admin is not authenticated", %{conn: conn} do
      conn = AdminAuth.redirect_if_admin_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_admin/2" do
    setup %{conn: conn} do
      %{conn: AdminAuth.fetch_current_scope_for_admin(conn, [])}
    end

    test "redirects if admin is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> AdminAuth.require_authenticated_admin([])
      assert conn.halted

      assert redirected_to(conn) == ~p"/admin/login"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> AdminAuth.require_authenticated_admin([])

      assert halted_conn.halted
      assert get_session(halted_conn, :admin_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> AdminAuth.require_authenticated_admin([])

      assert halted_conn.halted
      assert get_session(halted_conn, :admin_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> AdminAuth.require_authenticated_admin([])

      assert halted_conn.halted
      refute get_session(halted_conn, :admin_return_to)
    end

    test "does not redirect if admin is authenticated", %{conn: conn, admin: admin} do
      conn =
        conn
        |> assign(:current_scope, Scope.for_admin(admin))
        |> AdminAuth.require_authenticated_admin([])

      refute conn.halted
      refute conn.status
    end
  end
end
