use Mix.Config

# Authorize the device to receive firmware using your public key.
# See https://hexdocs.pm/nerves_firmware_ssh/readme.html for more information
# on configuring nerves_firmware_ssh.

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNet.Technology.Gadget}},
    {"wlan0", %{type: VintageNet.Technology.WiFi}}
  ]

config :vintage_net_wizard,
  dns_name: "volume-knob-config.local",
  port: 81

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
config :rotary_encoder, RotaryEncoder.Monitor,
  switch_gpio: 23,
  encoder_a_gpio: 24,
  encoder_b_gpio: 25,
  led_base_address: 0x68

config :sonex, Sonex.Discovery,
  net_device_name: "wlan0"

config :volume_knob, VolumeKnob.VolumeState,
  state_location: "/root/vol_knob_data.term"
