use Mix.Config

config :rotary_encoder, RotaryEncoder.Monitor,
  button_pin: 23,
  encoder_a_pin: 24,
  encoder_b_pin: 25,
  name: "main_volume"

config :rotary_encoder, RotaryEncoder.GpioPin, led_base_address: 0x68

config :sonex, Sonex.Discovery, net_device_name: "wlan0"

config :volume_knob, VolumeKnob.VolumeState, state_location: "/home/pi/vol_knob_data.term"
