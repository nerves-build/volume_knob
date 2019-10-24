defmodule VolumeKnobWeb.PageController do
  use VolumeKnobWeb, :controller

  alias VolumeKnob.VolumeState

  def index(conn, _params) do
    devices = Sonex.get_devices()
    current_device = VolumeState.get_current_device()

    {players, current_player} = case current_device do
      "" ->
        {[], nil}
      uuid ->
        plyr = %{coordinator_uuid: coordinator_uuid} = Sonex.get_player(uuid)
        {
          Sonex.players_in_zone(coordinator_uuid),
          plyr
        }
    end

    render(conn, "index.html", 
      conn: conn,
      devices: devices,
      current_device: current_device,
      current_player: current_player,
      players: players
    )
  end
end
