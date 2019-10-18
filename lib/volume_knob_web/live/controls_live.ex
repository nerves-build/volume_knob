defmodule VolumeKnobWeb.ControlsLive do
  use Phoenix.LiveView

  require Logger

  alias VolumeKnob.VolumeState

  def render(assigns) do
    Phoenix.View.render(VolumeKnobWeb.PageView, "_controls.html", assigns)
  end

  def mount(%{zones: zones, current_zone: current_zone}, socket) do

    {:ok, assign(socket, zones: zones, current_zone: current_zone)}
  end

  def handle_event("validate", %{"current" => current}, socket) do
    VolumeState.set_current_zone(current)

    {:noreply, decorate_socket(socket)}
  end

  def handle_info({:discovered, %ZonePlayer{} = new_device}, socket) do
    Logger.error("did receive discover ZonePlayer  emssage in app")

    {:noreply, decorate_socket(socket)}
  end

  def handle_info({:discovered, %SonosDevice{} = new_device}, socket) do
    Logger.error("did receive discover SonosDevice  emssage in app")

    {:noreply, decorate_socket(socket)}
  end

  defp decorate_socket(socket) do
    assign(socket,
      zones: Sonex.get_zones(),
      current_zone: VolumeState.get_current_zone)
  end

end
