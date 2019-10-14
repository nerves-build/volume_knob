# volume_knob

This is the companion source code for the blog post here:
https://nerves.build/posts/VolumeKnob


## Running in host mode
To get the VolumeKnob running initially run it in host mode
```
cd volume_knob
mix deps.get
mix phx.server
```

This should start the system and provide you with the UI at <code>http://localhost:4000</code>. This should interact with your Sonos system once it's logged into the local wifi network.


## Creating firmware
Once you are ready to burn the firware to an SD card run this:
```
cd vknob_fw
mix deps.get
mix firmware.burn
```

Report any issues you have with this software on the Issues here and it will be addressed.
