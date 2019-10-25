use Mix.Config



config :sonex, Sonex.Discovery,
  net_device_name: "wlan0"

config :volume_knob, VolumeState,
  state_location: "/home/pi/vol_knob_data.term"