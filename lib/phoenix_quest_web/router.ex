defmodule PhoenixQuestWeb.Router do
  use PhoenixQuestWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhoenixQuestWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixQuestWeb do
    pipe_through :browser

    get "/", PageController, :index

    live_session :game, root_layout: {PhoenixQuestWeb.LayoutView, :game} do
      live "/game", GameLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixQuestWeb do
  #   pipe_through :api
  # end
end
