defmodule VolumeKnobWeb.ControlsLive do
  use Phoenix.LiveView

  def render(%{socket: socket, zones: zones} = assigns) do
    Phoenix.View.render(VolumeKnobWeb.PageView, "_controls.html", assigns)
  end

  def mount(%{zones: zones} = prms, socket) do
    {:ok, assign(socket, :zones, zones)}
  end





end
