defmodule VolumeKnobWeb.Router do
  use VolumeKnobWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(:put_layout, {VolumeKnobWeb.LayoutView, :app})
  end

  scope "/", VolumeKnobWeb do
    pipe_through :browser
    live("/", ControlsLive, session: %{})
  end
end
