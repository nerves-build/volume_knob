defmodule VknobFw.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: VknobFw.Supervisor]

    children =
      [
        VknobFw.Device
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def children(_target) do
    []
  end

  def target() do
    Application.get_env(:vknob_fw, :target)
  end
end
