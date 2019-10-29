defmodule VolumeKnob.Device do

  use GenServer
  require Logger


  def start_link(_vars) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def set_current_zone(zone_uuid) do
    GenServer.call(__MODULE__, {:set_current_zone, zone_uuid})
  end

  def init(data) do
    {:ok, _} = Registry.register(RotaryEncoder, "click", [])
    {:ok, _} = Registry.register(RotaryEncoder, "travel", [])

    {:ok, data}
  end

  def handle_call(:get_current_zone, _from, %{current_zone: current_zone} = state) do
    {:reply, current_zone, state}
  end

  def handle_info({:click, down: true}, state) do
    {:noreply, state}
  end

  def handle_info({:click, down: false}, state) do
    VolumeKnob.VolumeState.get_current_device()
    |> Sonex.get_player()
    |> case do
        %{player_state: %{current_state: "stopped"}} = player ->
          Sonex.start_player(player)

        %{player_state: %{current_state: "playing"}} = player ->
          Sonex.stop_player(player)

        %{player_state: %{current_state: other}} ->
          Logger.debug("the unknowns state was #{other}")
      end
    {:noreply, state}
  end

  def handle_info({:travel, direction: :right}, state) do
    
    device = %{player_state: %{volume: volume}} =
      VolumeKnob.VolumeState.get_current_device()
      |> Sonex.get_player()

    Sonex.set_volume(device, Kernel.min(100, volume + 10))

    {:noreply, state}
  end

  def handle_info({:travel, direction: :left}, state) do
    device = %{player_state: %{volume: volume}} =
      VolumeKnob.VolumeState.get_current_device()
      |> Sonex.get_player()
    
    Sonex.set_volume(device, Kernel.max(0, volume - 10))

    {:noreply, state}
  end

end
