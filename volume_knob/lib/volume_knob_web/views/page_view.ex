defmodule VolumeKnobWeb.PageView do
  use VolumeKnobWeb, :view

  def draw_menu(_current_device, []) do
    content_tag(:h1, "scanning for devices...")
  end

  def draw_menu(current_device, devices) do
    ~E"""
    <div class="control">
    <div class="select">
    <select id="zones_field" class="form-control" name="current">
      <%= menu_option("Choose a Device", "", current_device) %>

      <%= for z <- devices do %>
        <%= menu_option(z.name, z.uuid, current_device) %>
      <% end %>
    </select>
    </div>
    </div>
    """
  end

  def menu_option(name, value, selected) when selected == value do
    content_tag(:option, name, value: value, selected: true)
  end

  def menu_option(name, value, _selected) do
    content_tag(:option, name, value: value)
  end

  def draw_vol_slider(nil), do: ""
  def draw_vol_slider(:missing), do: ""

  def draw_vol_slider(%{uuid: uuid, player_state: %{volume: %{l: _, m: volume, r: _}}}) do
    content_tag(:input, "",
      type: "range",
      "phx-click": "volume-slider",
      "phx-value-uuid": uuid,
      min: 1,
      max: 100,
      value: volume,
      class: "slider"
    )
  end

  def draw_vol_slider(_), do: ""

  def draw_playing_state(%{player_state: %{current_state: current_state}}) do
    current_state
  end

  def draw_vol_state(%{player_state: %{volume: %{l: _, m: volume, r: _}}}) do
    "VOL: #{volume}"
  end

  def draw_vol_state(_device), do: ""

  def draw_btn_image(_socket, nil), do: ""
  def draw_btn_image(_socket, :missing), do: ""

  def draw_btn_image(socket, %{uuid: uuid, player_state: %{current_state: "PLAYING"}}) do
    content_tag(:img, "",
      "phx-click": "pause-device",
      "phx-value-uuid": uuid,
      src: Routes.static_path(socket, "/images/pause.png"),
      width: "64px",
      height: "64px"
    )
  end

  def draw_btn_image(socket, %{player_state: %{current_state: "TRANSITIONING"}}) do
    content_tag(:img, "",
      src: Routes.static_path(socket, "/images/wait.png"),
      width: "64px",
      height: "64px"
    )
  end

  def draw_btn_image(socket, %{uuid: uuid, player_state: %{}}) do
    content_tag(:img, "",
      "phx-click": "play-device",
      "phx-value-uuid": uuid,
      src: Routes.static_path(socket, "/images/play.png"),
      width: "64px",
      height: "64px"
    )
  end
end
