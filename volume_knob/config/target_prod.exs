use Mix.Config

config :rotary_encoder, RotaryEncoder.Monitor,
  button_pin: 21,
  encoder_a_pin: 22,
  encoder_b_pin: 23,
  name: "main_volume"

config :tlc59116, Tlc59116.LedString, led_base_address: 0x68
