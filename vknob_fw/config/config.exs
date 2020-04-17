use Mix.Config

config :phoenix, :json_library, Jason

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

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

config :nerves_runtime, :kernel, use_system_registry: false

config :nerves_firmware_ssh, authorized_keys: Enum.map(keys, &File.read!/1)

config :volume_knob, VolumeKnobWeb.Endpoint,
  url: [host: "volumeknob.local", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: false,
  server: true,
  secret_key_base: "RVGBDiOsP7xkLie3Sm20g03CU9xCrEEcUgBpHk+wvR0rEwleVzjd2/c4zVmneYF9",
  http: [:inet6, port: 80],
  render_errors: [view: VolumeKnobWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: VolumeKnob.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "Gr/vYanKr/CC+SNJImqDE9TZYPUMIn/1"
  ]

config :logger, backends: [RingLogger], level: :info

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack],
  app: Mix.Project.config()[:app]

config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"wlan0", %{type: VintageNetWiFi}}
  ]

config :vintage_net_wizard,
  dns_name: "volumeknob-wifi.local",
  port: 4010,
  ssid: "volumeknob-setup",
  captive_portal: false

config :rotary_encoder, RotaryEncoder,
  encoders: [
    %{
      encoder_a_pin: 24,
      encoder_b_pin: 25,
      button_pin: 23,
      name: "main_volume"
    }
  ]

config :tlc59116, Tlc59116, led_base_address: 0x68

config :sonex, Sonex.Discovery, net_device_name: "wlan0"

config :volume_knob, VolumeKnob.VolumeState, state_location: "/root/vol_knob_data.term"

config :volume_knob, VolumeState,
  default: %{
    current_zone: ""
  }

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
