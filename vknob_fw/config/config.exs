use Mix.Config

config :vknob_fw, target: Mix.target()

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :phoenix, :json_library, Jason

config :shoehorn,
  init: [:nerves_runtime],
  app: Mix.Project.config()[:app]

config :volume_knob, VolumeKnobWeb.Endpoint,
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: "RVGBDiOsP7xkLie3Sm20g03CU9xCrEEcUgBpHk+wvR0rEwleVzjd2/c4zVmneYF9",
  render_errors: [view: VolumeKnobWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VolumeKnob.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Gr/vYanKr/CC+SNJImqDE9TZYPUMIn/1"
  ]

config :logger, backends: [RingLogger], level: :info

if Mix.target() != :host do
  import_config "target.exs"
end
