defmodule VolumeKnob.Device do

  use GenServer
  require Logger

  alias VolumeKnob.VolumeState

  @target Mix.target

  def start_link(_vars) do
    GenServer.start_link(__MODULE__, %{target: @target, last_down: nil, last_up: nil}, name: __MODULE__)
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

  def handle_info({:click, down: true}, %{last_up: last_up} = state) do
    state = %{state | last_down: :os.system_time(:millisecond)}
    Process.send_after(self(), {:test_btn_down, last_up}, 5000)
    {:noreply, state}
  end

  def handle_info({:test_btn_down, _}, %{target: :host} = state) do
    {:noreply, state}
  end

  def handle_info({:test_btn_down, old_last_up}, %{last_up: last_up} = state) do
    if (old_last_up == last_up) do
      IO.puts("starting init nextwork #{inspect(old_last_up)} - #{inspect(last_up)}")
      VintageNetWizard.run_wizard()
    end
    {:noreply, state}
  end

  def handle_info({:click, down: false}, state) do
    VolumeKnob.VolumeState.get_current_device()
    |> Sonex.get_player()
    |> case do
        %{player_state: %{current_state: "STOPPED"}} = player ->
          IO.puts("starting player #{inspect(player)}")
          Sonex.start_player(player)

        %{player_state: %{current_state: "PLAYING"}} = player ->
          IO.puts("stopping player #{inspect(player)}")
          Sonex.stop_player(player)

        %{player_state: %{current_state: other}} ->
          IO.puts("the unknowns state was #{other}")
      end

    state = %{state | last_up: :os.system_time(:millisecond)}
    {:noreply, state}
  end

  def handle_info({:travel, direction: :right}, state) do
    
    device = %{player_state: %{volume: %{m: volume}}} =
      VolumeKnob.VolumeState.get_current_device()
      |> Sonex.get_player()

    try do
      Sonex.set_volume(device, Kernel.min(99, String.to_integer(volume) + 3))
    rescue
      e in HTTPoison.Error ->
        Logger.error(inspect(e))
    end

    {:noreply, state}
  end

  def handle_info({:travel, direction: :left}, state) do
    device = %{player_state: %{volume: %{m: volume}}} =
      VolumeKnob.VolumeState.get_current_device()
      |> Sonex.get_player()
    
    try do
      Sonex.set_volume(device, Kernel.max(1, String.to_integer(volume) - 3))
    rescue
      e in HTTPoison.Error ->
        Logger.error(inspect(e))
    end

    {:noreply, state}
  end

  def handle_info({:updated, _new_device}, %{target: :host} = state),
    do: {:noreply, state}

  def handle_info({:updated, _new_device}, state) do
    VolumeKnob.VolumeState.get_current_device()
    |> Sonex.get_player()
    |> case do
      nil -> :ok
      %{player_state: %{volume: %{m: vol}}} ->
        vol
        |> String.to_integer
        |> RotaryEncoder.set_value
      other -> :ok
    end
    {:noreply, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}
end
