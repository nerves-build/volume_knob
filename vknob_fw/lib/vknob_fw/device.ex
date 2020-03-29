defmodule VknobFw.Device do
  use GenServer
  require Logger

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
    :ok = VintageNet.subscribe(["interface", "wlan0"])

    {:ok, data}
  end

  def handle_info({:click, %{type: :up, duration: duration}}, state) when duration > 5000 do
    #  VintageNetWizard.run_wizard()

    {:noreply, state}
  end

  def handle_info({VintageNet, name, old_value, new_value, metadata}, state) do
    Logger.error(
      "the VintageNet event name is #{name} - #{inspect(old_value)} - #{inspect(new_value)} - #{
        inspect(metadata)
      }"
    )

    {:noreply, state}
  end
end
