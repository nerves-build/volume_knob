defmodule VolumeKnobWeb.ControlsLive do
  use Phoenix.LiveView

  alias VolumeKnob.VolumeState

  def render(assigns) do
    Phoenix.View.render(VolumeKnobWeb.PageView, "_controls.html", assigns)
  end

  def mount(%{zones: zones, current_zone: current_zone}, socket) do
    {:ok, assign(socket, zones: zones, current_zone: current_zone)}
  end

  def handle_event("validate", %{"current" => current}, socket) do
    VolumeState.set_current_zone(current)

    {:noreply, assign(socket, zones: Sonex.get_zones(), current_zone: current)}
  end




end
