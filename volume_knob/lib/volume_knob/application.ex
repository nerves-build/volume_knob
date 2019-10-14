defmodule VolumeKnob.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      VolumeKnobWeb.Endpoint,
      VolumeKnob.VolumeState,
      VolumeKnob.Device
    ]

    opts = [strategy: :one_for_one, name: VolumeKnob.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    VolumeKnobWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
