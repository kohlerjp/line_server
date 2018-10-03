defmodule LineServerWeb.LineControllerTest do
  use LineServerWeb.ConnCase

  test "GET /lines/id", %{conn: conn} do
    conn = get conn, "/lines/0"
    assert json_response(conn, 200)
  end

  test "Getting line out of bounds returns 413", %{conn: conn} do
    conn = get conn, "/lines/3000"
    assert json_response(conn, 413)
  end
end
