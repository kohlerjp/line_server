defmodule LineServerWeb.PageController do
  use LineServerWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
