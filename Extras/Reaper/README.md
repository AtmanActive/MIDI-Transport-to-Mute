# MIDI-Transport-to-Mute

This directory contains extra goodies for [Reaper](https://reaper.fm) to enable true Studio Talkback functionality.

## JSFX

There is a modified volume control JS effect for Reaper which is used for dimming the monitoring FX chain volume, but with the added benefit of auto-resetting to 0dB on each and every transport action (stop, play, record), thus making sure talkback dimming can't get stuck in an unwanted state.

The name of the file is monitoring_fx_talkback_dimmer. To add it to your Reaper, just copy-paste the file to Reaper/Effects directory. Then run Reaper and add this effect to your Monitoring FX Chain.


