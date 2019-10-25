use Mix.Config


config :sonex, Sonex.Discovery,
  net_device_name: "en0"


config :volume_knob, VolumeState,
  state_location: "/Users/steve/root/vol_knob_data.term"