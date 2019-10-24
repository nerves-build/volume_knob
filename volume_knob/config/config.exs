# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sonex, []

config :volume_knob, VolumeState,
  default: %{
    current_zone: ""
  }

# Configures the endpoint
config :volume_knob, VolumeKnobWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RVGBDiOsP7xkLie3Sm20g03CU9xCrEEcUgBpHk+wvR0rEwleVzjd2/c4zVmneYF9",
  render_errors: [view: VolumeKnobWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VolumeKnob.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Gr/vYanKr/CC+SNJImqDE9TZYPUMIn/1"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
