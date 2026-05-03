defmodule InnosoWeb.PageControllerTest do
  use InnosoWeb.ConnCase

  test "GET / renders landing page", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Innoso"
  end
end
