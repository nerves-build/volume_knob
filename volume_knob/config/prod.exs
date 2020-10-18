use Mix.Config

config :volume_knob, VolumeKnobWeb.Endpoint,
  url: [host: "volumeknob.local", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
