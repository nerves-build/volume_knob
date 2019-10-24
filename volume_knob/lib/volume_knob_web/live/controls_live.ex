defmodule VolumeKnobWeb.ControlsLive do
  use Phoenix.LiveView

  require Logger

  alias VolumeKnob.VolumeState

  def render(assigns) do
    Phoenix.View.render(VolumeKnobWeb.PageView, "_controls.html", assigns)
  end

  def mount(%{}, socket) do
    {:ok, pid} = Registry.register(Sonex, "devices", [])

    {:ok, decorate_socket(socket)}
  end

  def handle_event("validate", %{"current" => current}, socket) do
    VolumeState.set_current_device(current)

    {:noreply, decorate_socket(socket)}
  end

  def handle_event("pause-device", %{"uuid" => uuid}, socket) do
    Sonex.get_player(uuid)
    |> Sonex.stop_player()

     {:noreply, socket}
  end

  def handle_event("play-device", %{"uuid" => uuid}, socket) do
    Sonex.get_player(uuid)
    |> IO.inspect(label: "in handle-event")
    |> Sonex.start_player()

     {:noreply, socket}
  end

  def handle_event("volume-slider", %{"uuid" => uuid, "value" => value}, socket) do
    Sonex.get_player(uuid)
    |> Sonex.set_volume(value)

     {:noreply, socket}
  end

  def handle_info({:discovered, _new_device}, socket) do
    {:noreply, decorate_socket(socket)}
  end

  def handle_info({:updated, _new_device}, socket) do
    {:noreply, decorate_socket(socket)}
  end

  defp decorate_socket(socket) do
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

    assign(socket,
      devices: Sonex.get_devices(),
      current_device: current_device,
      current_player: current_player,
      players: players
    )
  end
end
