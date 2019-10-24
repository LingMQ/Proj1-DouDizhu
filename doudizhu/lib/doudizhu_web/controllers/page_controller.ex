defmodule DoudizhuWeb.PageController do
  use DoudizhuWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def game(conn, %{"name" => name, "player" => player}) do
    render(conn, "game.html", name: name, player: player)
  end
end
