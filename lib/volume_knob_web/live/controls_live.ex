defmodule VolumeKnobWeb.ControlsLive do
  use Phoenix.LiveView

  require Logger

  alias VolumeKnob.VolumeState

  def render(assigns) do
    Phoenix.View.render(VolumeKnobWeb.PageView, "_controls.html", assigns)
  end

  def mount(%{zones: zones, current_zone: current_zone}, socket) do
    {:ok, pid} = Registry.register(Sonex, "devices", [])

    {:ok, decorate_socket(socket)}
  end

  def handle_event("validate", %{"current" => current}, socket) do
    VolumeState.set_current_zone(current)

    {:noreply, decorate_socket(socket)}
  end

  def handle_info({:discovered, _new_device}, socket) do
    {:noreply, decorate_socket(socket)}
  end

  def handle_info({:updated, _new_device}, socket) do
    {:noreply, decorate_socket(socket)}
  end

  defp decorate_socket(socket) do
    current_zone = VolumeState.get_current_zone()
    %{coord: coord, player: player} = Sonex.get_grouped_players_in_zone(current_zone)

    assign(socket,
      zones: Sonex.get_zones(),
      current_zone: current_zone,
      current_coord: coord,
      players: player
    )
  end
end
