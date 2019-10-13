defmodule VolumeKnobWeb.PageController do
  use VolumeKnobWeb, :controller

  def index(conn, _params) do
    zones = Sonex.get_zones()
    render(conn, "index.html", conn: conn, zones: zones)
  end
end
