defmodule VknobFw.Device do
  use GenServer
  require Logger

  @target Mix.target()

  def start_link(_vars) do
    GenServer.start_link(__MODULE__, %{target: @target, last_down: nil, last_up: nil},
      name: __MODULE__
    )
  end

  def init(data) do
    {:ok, _} = RotaryEncoder.subscribe("main_volume")
    :ok = VintageNet.subscribe(["interface", "wlan0"])
    Tlc59116.set_mode(:sparkle)

    {:ok, data}
  end

  def handle_info({:click, %{type: :up, duration: duration}}, state) when duration > 5000 do
    VintageNetWizard.run_wizard()

    {:noreply, state}
  end

  def handle_info(
        {VintageNet, ["interface", _, "connection"], _, :internet, _metadata},
        state
      ) do
    Tlc59116.set_mode(:cylon)

    {:noreply, state}
  end

  def handle_info(
        {VintageNet, ["interface", _, "connection"], _, :disconnected, _metadata},
        state
      ) do
    Tlc59116.set_mode(:sparkle)

    {:noreply, state}
  end

  def handle_info({VintageNet, ["interface", _, _, "access_points"], _, _, _metadata}, state) do
    {:noreply, state}
  end

  def handle_info({VintageNet, _name, _old_value, _new_value, _metadata}, state) do
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
