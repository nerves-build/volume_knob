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
    IO.puts("the click is down")
    {:noreply, state}
  end

  def handle_info({:click, down: false}, state) do
    IO.puts("the click is up")
    {:noreply, state}
  end

  def handle_info({:travel, direction: :right}, state) do
    IO.puts("the click is right")
    {:noreply, state}
  end

  def handle_info({:travel, direction: :left}, state) do
    IO.puts("the click is left")
    {:noreply, state}
  end

end
