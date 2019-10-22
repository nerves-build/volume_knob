defmodule VolumeKnobWeb.PageView do
  use VolumeKnobWeb, :view

  def menu_option(name, value, selected) when selected == value do
    ~E"""
      <option value="<%= value %>" selected>
        <%= name %>
      </option>
    """
  end

  def menu_option(name, value, _selected) do
    ~E"""
      <option value="<%= value %>">
        <%= name %>
      </option>
    """
  end

  def draw_vol_slider(socket, %{player_state: %{volume: %{l: "100", m: volume, r: "100"}}}) do
    ~E"""
      <input type="range" min="0" max="100" value="<%= volume %>" class="slider">
    """
  end


  def draw_btn_image(socket, %{player_state: %{current_state: "PLAYING"}}) do
    ~E"""
      <img src=<%= Routes.static_path(socket, "/images/pause.png") %> WIDTH=64px HEIGHT=64px>
    """
  end

  def draw_btn_image(socket, %{player_state: %{}}) do
    ~E"""
      <img src=<%= Routes.static_path(socket, "/images/play.png") %> WIDTH=64px HEIGHT=64px>
    """
  end

  def display_device(p) do
    ~E"""
      <%= p.name %> == <%= p.__struct__ %> == <%= p.uuid %> == <%= p.coordinator_uuid %>
    """
  end
end
