defmodule DoudizhuWeb.PageControllerTest do
  use DoudizhuWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Fight"
  end
end
