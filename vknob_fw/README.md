# VknobFw

This is the firmware app for the Sonos VolumeKnob

## Targets
Currently has only ben tested on an RPI0W but should work on a Nerves compatible board.

## Getting Started

To start your Nerves app:
  * `export MIX_TARGET=my_target` or prefix every command with
    `MIX_TARGET=my_target`. For example, `MIX_TARGET=rpi0`
  * Install dependencies with `mix deps.get`
  * Create firmware with `mix firmware`
  * Burn to an SD card with `mix firmware.burn`
  * Look for your device to show up at `http://volumeknob.local`