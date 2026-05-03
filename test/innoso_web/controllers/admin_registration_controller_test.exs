defmodule InnosoWeb.AdminRegistrationControllerTest do
  use InnosoWeb.ConnCase

  import Innoso.AccountsFixtures

  describe "GET /admin/login" do
    test "login page does not have public registration", %{conn: conn} do
      conn = get(conn, ~p"/admin/login")
      response = html_response(conn, 200)
      assert response =~ "Sign in"
      refute response =~ "Register"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_admin(admin_fixture()) |> get(~p"/admin/login")
      assert redirected_to(conn) == ~p"/admin"
    end
  end
end
