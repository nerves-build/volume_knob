use Mix.Config

config :rotary_encoder, RotaryEncoder.Monitor,
  switch_gpio: 23,
  encoder_a_gpio: 24,
  encoder_b_gpio: 25

config :sonex, Sonex.Discovery,
  net_device_name: "wlan0"

config :volume_knob, VolumeKnob.VolumeState,
  state_location: "/home/pi/vol_knob_data.term"