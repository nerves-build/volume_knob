defmodule VolumeKnobWeb.PageController do
  use VolumeKnobWeb, :controller

  alias VolumeKnob.VolumeState

  def index(conn, _params) do
    zones = Sonex.get_zones()
    current_zone = VolumeState.get_current_zone()

    render(conn, "index.html", conn: conn, zones: zones, current_zone: current_zone)
  end
end
