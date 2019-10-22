defmodule VolumeKnobWeb.PageController do
  use VolumeKnobWeb, :controller

  alias VolumeKnob.VolumeState

  def index(conn, _params) do
    zones = Sonex.get_zones()
    current_zone = VolumeState.get_current_zone()
    %{coord: coord, player: player} = Sonex.get_grouped_players_in_zone(current_zone)

    render(conn, "index.html", 
      conn: conn,
      zones: zones,
      current_zone: current_zone,
      current_coord: coord,
      players: player,
    )
  end
end
