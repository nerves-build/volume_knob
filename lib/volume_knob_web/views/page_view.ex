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
end
