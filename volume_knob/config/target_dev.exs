use Mix.Config

config :rotary_encoder, RotaryEncoder,
  encoders: [
    %{
      encoder_a_pin: 19,
      encoder_b_pin: 20,
      button_pin: 21,
      name: "main_volume"
    }
  ]

config :tlc59116, Tlc59116.LedString, led_base_address: 0x68
