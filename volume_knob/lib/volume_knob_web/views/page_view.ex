defmodule VolumeKnobWeb.PageView do
  use VolumeKnobWeb, :view

  def draw_device(%{uuid: uuid, coordinator_uuid: coordinator_uuid, name: name, ip: ip} = player) do
    ~E"""
      <div id="player_display" class="tile is-ancestor">
        <div class="tile is-vertical no-padding">
          <div class="level is-mobile lite-pad has-background-grey-light has-text-black-ter">
            <div class="level-item is-8 font-left has-text-weight-semibold">
              <%= name %>
            </div>
            <div class="level-item is-4 font-right ip_font">
              <%= ip %>
            </div>
          </div>
          <div class="level is-mobile lite-pad">
            <div class="level-item is-8 action_font font-left">
              <%= draw_playing_state(player) %>
            </div>
            <div class="level-item is-4 has-text-right ip_font font-right">
              <%= draw_vol_state(player) %>
            </div>
          </div>
        <%= if uuid == coordinator_uuid do %>
          <div class="level action_font lite-pad">
            <div class="level-item is-8 action_font font-left">
             Coordinator
            </div>
          </div>
        <% end %>
        </div>
      </div>
    """
  end

  def draw_menu(current_device, []) do
    ~E"""
      <label>
        <%= menu_option("scanning for devices...", "", current_device) %>
      </label>
    """
  end

  def draw_menu(current_device, devices) do
    ~E"""
      <select id="zones_field" class="form-control" name="current">
        <%= menu_option("Choose a Device", "", current_device) %>

        <%= for z <- devices do %>
          <%= menu_option(z.name, z.uuid, current_device) %>
        <% end %>
      </select>
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
  def draw_vol_slider(:missing), do: ""

  def draw_vol_slider(%{uuid: uuid, player_state: %{volume: %{l: "100", m: volume, r: "100"}}}) do
    ~E"""
      <input type="range" min="1" max="100" value="<%= volume %>" class="slider" phx-click="volume-slider" phx-value-uuid="<%= uuid %>">
    """
  end

  def draw_vol_slider(_), do: ""

  def draw_playing_state(%{player_state: %{current_state: current_state}}) do
    current_state
  end

  def draw_track_state(nil) do
    ""
  end

  def draw_track_state(:missing) do
    ""
  end

  def draw_track_state(%{
        player_state: %{current_track: current_track, track_info: %{title: title}}
      }) do
    "Track: #{current_track} - info: #{inspect(title)}"
  end

  def draw_track_state(device) do
    IO.puts("error draw_track_state: #{inspect(device)}")
  end

  def draw_vol_state(%{player_state: %{volume: %{l: "100", m: volume, r: "100"}}}) do
    "VOL: #{volume}"
  end

  def draw_vol_state(device) do
    IO.puts("error draw_vol_state: #{inspect(device)}")
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
  def draw_btn_image(_socket, :missing), do: ""
  # def draw_btn_image(_socket, %{player_state: %{track_info: %{title: nil}}}), do: ""

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
