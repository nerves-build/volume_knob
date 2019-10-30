use Mix.Config

config :volume_knob, VolumeState,
  default: %{
    current_zone: ""
  }

config :volume_knob, VolumeKnobWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RVGBDiOsP7xkLie3Sm20g03CU9xCrEEcUgBpHk+wvR0rEwleVzjd2/c4zVmneYF9",
  render_errors: [view: VolumeKnobWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VolumeKnob.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Gr/vYanKr/CC+SNJImqDE9TZYPUMIn/1"
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{Mix.env()}.exs"

if Mix.target() != :host do
  import_config "target.exs"
else
  import_config "host.exs"
end
