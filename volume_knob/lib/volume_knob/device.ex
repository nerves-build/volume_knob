defmodule VolumeKnob.Device do
  use GenServer
  require Logger

  alias VolumeKnob.VolumeState

  @target Mix.target()

  def start_link(_vars) do
    GenServer.start_link(__MODULE__, %{target: @target, last_down: nil, last_up: nil},
      name: __MODULE__
    )
  end

  def set_current_zone(zone_uuid) do
    GenServer.call(__MODULE__, {:set_current_zone, zone_uuid})
  end

  def init(data) do
    {:ok, _} = RotaryEncoder.subscribe("main_volume")
    {:ok, _} = Registry.register(Sonex, "devices", [])

    {:ok, data}
  end

  def handle_info({:click, %{type: :up, duration: duration}}, state) when duration > 5000 do
    #  VintageNetWizard.run_wizard()

    {:noreply, state}
  end

  def handle_info({:click, %{type: :up}}, state) do
    VolumeState.get_current_device()
    |> Sonex.get_player()
    |> toggle_playing

    {:noreply, state}
  end

  def handle_info({:click, %{type: :down}}, state) do
    {:noreply, state}
  end

  def handle_info({:travel, %{direction: :cw}}, state) do
    VolumeState.get_current_device()
    |> Sonex.get_player()
    |> increment_volume(3)

    {:noreply, state}
  end

  def handle_info({:travel, %{direction: :ccw}}, state) do
    VolumeState.get_current_device()
    |> Sonex.get_player()
    |> increment_volume(-3)

    {:noreply, state}
  end

  def handle_info({:discovered, _new_device}, state) do
    {:noreply, state}
  end

  def handle_info({:updated, _new_device}, state) do
    VolumeState.get_current_device()
    |> Sonex.get_player()
    |> case do
      nil ->
        :ok

      %{player_state: %{volume: %{m: vol}}} ->
        Tlc59116.set_mode(:normal)
        Tlc59116.set_level(vol)
        :ok

      _other ->
        :ok
    end

    {:noreply, state}
  end

  defp increment_volume(%{player_state: %{volume: %{m: volume}}} = device, amount) do
    try do
      Sonex.set_volume(device, Kernel.min(99, String.to_integer(volume) + amount))
    rescue
      e in HTTPoison.Error ->
        Logger.error("increment_volume error #{inspect(e)}")
    end
  end

  defp toggle_playing(player) do
    case player do
      %{player_state: %{current_state: "PAUSED_PLAYBACK"}} ->
        Sonex.start_player(player)

      %{player_state: %{current_state: "STOPPED"}} ->
        Sonex.start_player(player)

      %{player_state: %{current_state: "PLAYING"}} ->
        Sonex.stop_player(player)

      %{player_state: %{current_state: other}} ->
        Logger.warn("the unknowns state was #{other}")
    end
  end
end