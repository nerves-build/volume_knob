defmodule VknobFw.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: VknobFw.Supervisor]

    children = [
      VknobFw.Device
    ]

    Supervisor.start_link(children, opts)
  end
end
