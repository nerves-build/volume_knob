use Mix.Config

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

config :nerves_runtime, :kernel, use_system_registry: false

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack],
  app: Mix.Project.config()[:app]

config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"usb0", %{type: VintageNetDirect}},
    {"wlan0",
     %{
       type: VintageNetWiFi,
       vintage_net_wifi: %{
         networks: [
           %{
             key_mgmt: :wpa_psk,
             ssid: "steves_network",
             psk: "francine2"
           }
         ]
       },
       ipv4: %{method: :dhcp}
     }}
  ]

config :rotary_encoder, RotaryEncoder,
  encoders: [
    %{
      encoder_a_pin: 24,
      encoder_b_pin: 25,
      button_pin: 23,
      name: "main_volume"
    }
  ]

config :rotary_encoder, RotaryEncoderTest, Circuits.GPIO

config :tlc59116, Tlc59116.LedString, led_base_address: 0x68

config :sonex, Sonex.Discovery, net_device_name: "wlan0"

config :volume_knob, VolumeKnob.VolumeState, state_location: "/root/vol_knob_data.term"

config :mdns_lite,
  host: [:hostname, "volumeknob"],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      name: "SSH Remote Login Protocol",
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Secure File Transfer Protocol over SSH",
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Erlang Port Mapper Daemon",
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]
