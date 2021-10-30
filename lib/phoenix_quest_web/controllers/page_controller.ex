defmodule PhoenixQuestWeb.PageController do
  use PhoenixQuestWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
