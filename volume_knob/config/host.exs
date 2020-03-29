use Mix.Config

config :rotary_encoder, RotaryEncoder, gpio_handler: RotaryEncoder.MockGpioPin

config :tlc59116, Tlc59116, i2c_handler: Tlc59116.MockI2CPin

config :sonex, Sonex.Discovery, net_device_name: "en0"

config :volume_knob, VolumeKnob.VolumeState,
  state_location: "/Users/steve/root/vol_knob_data.term"
