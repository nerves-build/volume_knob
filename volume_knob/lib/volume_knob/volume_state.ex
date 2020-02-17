defmodule VolumeKnob.VolumeState do
  defmodule State do
    defstruct current_zone: "", current_device: "", fresh: false
  end

  use GenServer
  require Logger

  @file_location Application.get_env(:volume_knob, VolumeKnob.VolumeState)[:state_location]

  def start_link(_vars) do
    GenServer.start_link(__MODULE__, initial_data(), name: __MODULE__)
  end

  def set_current_zone(zone_uuid) do
    GenServer.call(__MODULE__, {:set_current_zone, zone_uuid})
  end

  def is_fresh?() do
    %{
      fresh: fresh
    } = GenServer.call(__MODULE__, :get_state)

    fresh
  end

  def get_current_zone() do
    GenServer.call(__MODULE__, :get_current_zone)
  end

  def set_current_device(device_uuid) do
    GenServer.call(__MODULE__, {:set_current_device, device_uuid})
  end

  def get_current_device() do
    GenServer.call(__MODULE__, :get_current_device)
  end

  def init(data) do
    {:ok, data}
  end

  def handle_call(:get_current_zone, _from, %{current_zone: current_zone} = state) do
    {:reply, current_zone, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_current_zone, zone_uuid}, _from, state) do
    new_data = %{state | current_zone: zone_uuid}

    flush(new_data)
    {:reply, new_data, new_data}
  end

  def handle_call(:get_current_device, _from, %{current_device: current_device} = state) do
    {:reply, current_device, state}
  end

  def handle_call({:set_current_device, device_uuid}, _from, state) do
    new_data = %{state | current_device: device_uuid}

    flush(new_data)
    {:reply, new_data, new_data}
  end

  def terminate(reason, _state) do
    Logger.error("exiting RuntimeConfig.State due to #{inspect(reason)}")
  end

  defp flush(state) do
    File.write!(@file_location, :erlang.term_to_binary(state))
  end

  defp initial_data do
    defs = Application.get_env(:volume_knob, VolumeState)[:default]

    defs =
      if File.exists?(@file_location) do
        existing =
          @file_location
          |> File.read!()
          |> :erlang.binary_to_term()
          |> IO.inspect(label: "existing")

        defs
        |> Map.merge(existing)
      else
        File.open!(@file_location, [:read, :write])
        File.write!(@file_location, :erlang.term_to_binary(defs))

        Map.put(defs, :fresh, true)
      end

    IO.puts("starting")

    defs =
      case defs do
        %_{} = d ->
          Map.from_struct(d)

        m ->
          m
      end

    struct(State, defs)
  end
end
