use Mix.Config

config :vknob_fw, target: Mix.target()

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :phoenix, :json_library, Jason

config :volume_knob, VolumeState,
  default: %{
    current_zone: ""
  }

config :nerves_firmware_ssh,
  authorized_keys: [
    File.read!(Path.join(System.user_home!, ".ssh/id_rsa.pub"))
  ]

config :shoehorn,
  init: [:nerves_runtime, :vintage_net, :nerves_firmware_ssh],
  app: Mix.Project.config()[:app]

config :volume_knob, VolumeKnobWeb.Endpoint,
  url: [host: "volume-knob.local", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: false,
  server: true,
  secret_key_base: "RVGBDiOsP7xkLie3Sm20g03CU9xCrEEcUgBpHk+wvR0rEwleVzjd2/c4zVmneYF9",
  http: [:inet6, port: 80],
  render_errors: [view: VolumeKnobWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VolumeKnob.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Gr/vYanKr/CC+SNJImqDE9TZYPUMIn/1"
  ]

config :logger, backends: [RingLogger], level: :info

if Mix.target() != :host do
  import_config "target.exs"
end
