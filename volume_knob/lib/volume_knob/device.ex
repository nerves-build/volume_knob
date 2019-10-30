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
    {:ok, _} = Registry.register(Sonex, "devices", [])

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
        %{player_state: %{current_state: "STOPPED"}} = player ->
          Sonex.start_player(player)

        %{player_state: %{current_state: "PLAYING"}} = player ->
          Sonex.stop_player(player)

        %{player_state: %{current_state: other}} ->
          Logger.debug("the unknowns state was #{other}")
      end
    {:noreply, state}
  end

  def handle_info({:travel, direction: :right}, state) do
    
    device = %{player_state: %{volume: %{m: volume}}} =
      VolumeKnob.VolumeState.get_current_device()
      |> Sonex.get_player()

    Sonex.set_volume(device, Kernel.min(99, String.to_integer(volume) + 3))

    {:noreply, state}
  end

  def handle_info({:travel, direction: :left}, state) do
    device = %{player_state: %{volume: %{m: volume}}} =
      VolumeKnob.VolumeState.get_current_device()
      |> Sonex.get_player()
    
    Sonex.set_volume(device, Kernel.max(1, String.to_integer(volume) - 3))

    {:noreply, state}
  end

  def handle_info({:updated, _new_device}, state) do
    VolumeKnob.VolumeState.get_current_device()
    |> Sonex.get_player()
    |> case do
      nil -> :ok
      %{player_state: %{volume: %{m: vol}}} ->
        vol
        |> String.to_integer
        |> RotaryEncoder.set_value
      other ->
        IO.inspect(other, label: "other")
    end
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
