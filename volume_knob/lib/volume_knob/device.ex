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

  def init(data) do
    {:ok, _} = RotaryEncoder.subscribe("main_volume")
    {:ok, _} = Registry.register(Sonex, "devices", [])

    {:ok, data}
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

  def handle_info({:discovered, %SonosDevice{uuid: uuid}}, state) do
    Tlc59116.set_mode(:normal)
    {:noreply, state}
  end

  def handle_info({:updated, _new_device}, state) do
    VolumeState.get_current_device()
    |> Sonex.get_player()
    |> case do
      nil ->
        :ok

      %{player_state: %{volume: %{m: vol}}} ->
        vol
        |> String.to_integer()
        |> Tlc59116.set_value()

        Tlc59116.set_mode(:normal)

        :ok

      _other ->
        :ok
    end

    {:noreply, state}
  end

  defp increment_volume(nil, _), do: :noop

  defp increment_volume(%{player_state: %{volume: %{m: volume}}} = device, amount) do
    try do
      Tlc59116.set_mode(:normal)
      Sonex.set_volume(device, Kernel.min(99, String.to_integer(volume) + amount))
    rescue
      e in HTTPoison.Error ->
        Logger.error("increment_volume error #{inspect(e)}")
    end
  end

  defp toggle_playing(nil), do: :noop

  defp toggle_playing(player) do
    case player do
      %{player_state: %{current_state: "PAUSED_PLAYBACK"}} ->
        Sonex.start_player(player)

      %{player_state: %{current_state: "STOPPED"}} ->
        Sonex.start_player(player)

      %{player_state: %{current_state: "PLAYING"}} ->
        Sonex.stop_player(player)

      %{player_state: %{current_state: other}} ->
        Logger.warn("Unknown player state was #{other}")
    end
  end
end
