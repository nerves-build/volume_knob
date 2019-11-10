defmodule VolumeKnobWeb.PageView do
  use VolumeKnobWeb, :view

  def draw_device(%{uuid: uuid, coordinator_uuid: coordinator_uuid, name: name, ip: ip} = player) do
    ~E"""
      <div class="card">
        <%= if uuid == coordinator_uuid do %>
          <div class="card-header">
            Coordinator
          </div>
        <% end %>
        <div class="card-body">
          <div class="row">
            <div class="card-title col-sm-7 col">
              <%= name %>
            </div>
            <div class="col-sm-5 col ip_font">
              <%= ip %>
            </div>
          </div>
          <div class="row">
            <div class="col-sm-8 col action_font">
              <%= draw_playing_state(player) %>
            </div>
            <div class="col-sm-4 col action_font">
              <%= draw_vol_state(player) %>
            </div>
          </div>
        </div>
      </div>
    """
  end

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

  def draw_vol_slider(nil), do: ""
  def draw_vol_slider(%{uuid: uuid, player_state: %{volume: %{l: "100", m: volume, r: "100"}}}) do
    ~E"""
      <input type="range" min="0" max="100" value="<%= volume %>" class="form-control-range slider" phx-click="volume-slider" phx-value-uuid="<%= uuid %>" WIDTH=100%>
    """
  end
  def draw_vol_slider(_), do: ""

  def draw_playing_state(%{player_state: %{current_state: current_state}}) do
    current_state
  end

  def draw_track_state(nil) do
    ""
  end

  def draw_track_state(%{player_state: %{current_track: current_track, track_info: %{title: title}}}) do
    "Track: #{current_track} - info: #{inspect(title)}"
  end

  def draw_vol_state(%{player_state: %{volume: %{l: "100", m: volume, r: "100"}}}) do
    "V: #{volume}"
  end

  def draw_btn_sm_image(_socket, ""), do: ""

  def draw_btn_sm_image(socket, %{player_state: %{current_state: "PLAYING"}}) do
    ~E"""
      <img src=<%= Routes.static_path(socket, "/images/pause.png") %> WIDTH=16px HEIGHT=16px>
    """
  end

  def draw_btn_sm_image(socket, %{player_state: %{current_state: "TRANSITIONING"}}) do
    ~E"""
      <img src=<%= Routes.static_path(socket, "/images/wait.png") %> WIDTH=16px HEIGHT=16px>
    """
  end

  def draw_btn_sm_image(socket, %{player_state: %{}}) do
    ~E"""
      <img src=<%= Routes.static_path(socket, "/images/play.png") %> WIDTH=16px HEIGHT=16px>
    """
  end

  def draw_btn_image(_socket, nil), do: ""
  def draw_btn_image(_socket, %{player_state: %{track_info: %{title: nil}}}), do: ""
  def draw_btn_image(socket, %{uuid: uuid, player_state: %{current_state: "PLAYING"}}) do
    ~E"""
      <img src=<%= Routes.static_path(socket, "/images/pause.png") %> WIDTH=64px HEIGHT=64px phx-click="pause-device" phx-value-uuid="<%= uuid %>">
    """
  end

  def draw_btn_image(socket, %{player_state: %{current_state: "TRANSITIONING"}}) do
    ~E"""
      <img src=<%= Routes.static_path(socket, "/images/wait.png") %> WIDTH=64px HEIGHT=64px>
    """
  end

  def draw_btn_image(socket, %{uuid: uuid, player_state: %{}}) do
    ~E"""
      <img src=<%= Routes.static_path(socket, "/images/play.png") %> WIDTH=64px HEIGHT=64px phx-click="play-device" phx-value-uuid="<%= uuid %>">
    """
  end

  def display_device(p) do
    ~E"""
      <%= p.name %> == <%= p.__struct__ %> == <%= p.uuid %> == <%= p.coordinator_uuid %>
    """
  end
end
