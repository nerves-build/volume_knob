use Mix.Config

config :volume_knob, VolumeKnobWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
