defmodule DoudizhuWeb.PageController do
  use DoudizhuWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html", name: "demo")
  end
end
