# MIDI-Transport-to-Mute

This directory contains extra goodies for [Reaper](https://reaper.fm) to enable true Studio Talkback functionality.

## JSFX

There is a modified volume control JS effect for Reaper which is used for dimming the monitoring FX chain volume, but with the added benefit of auto-resetting to 0dB on each and every transport action (stop, play, record), thus making sure talkback dimming can't get stuck in an unwanted state.

The name of the file is monitoring_fx_talkback_dimmer. To add it to your Reaper, just copy-paste the file to Reaper/Effects directory. Then run Reaper and add this effect to your Monitoring FX Chain.

## ReaLearn

The other piece of the puzzle is [ReaLearn](https://www.helgoboss.org/projects/realearn) which is a plug-in for Reaper to enable system-wide automation.

Once you have ReaLearn installed in your Reaper, add a ReaLearn instance to your Monitoring FX and import the file ReaLearn TalkBack Instance.json from this repository into it.

