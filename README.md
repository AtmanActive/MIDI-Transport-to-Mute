# MIDI-Transport-to-Mute

A windows app to mute an audio input based on incoming [Mackie Transport Control](https://en.wikipedia.org/wiki/REAPER#Control_surface_support_and_remote_control) (MTC) [MIDI](https://en.wikipedia.org/wiki/MIDI) signals.

## Preparation

- Install a virtual MIDI cable software like [loopMIDI](https://www.tobias-erichsen.de/software/loopmidi.html) or [Bome Network](https://www.bome.com/products/bomenet) or similar. 
- Create two virtual MIDI cables, one will be MTC input, the other one MTC output. 
- Go to windows "Sound"->"Recording" control panel and rename your microphone input device to "MicInput" 
by double-clicking on the device, typing the name and clicking OK. 
- Start your DAW, configure MTC output to one virtual cable. 
You can put the MTC input on the other cable, or leave it blank, if your DAW would allow. 
Do not use one and the same MIDI cable for both MTC input and output in your DAW, that would only create a loopback. 
- Start this app, choose the MIDI port you assigned to MTC output previously as this app's Mute Events MIDI input port.

## Running
Now, whenever you press play in your DAW, your microphone should be muted which is indicated by 
the tray icon color change to red. As soon as you press stop in your DAW, your microphone will be 
unmuted which is indicated by the green tray icon.

To use this online with several correspondents at the same time, checkout this project: [webmidi-rtc-transport](https://github.com/AtmanActive/webmidi-rtc-transport)

## Talkback functionality since version 2.0
In addition to muting/unmuting from MIDI signals coming from a DAW, you can now also use the talkback functionality.
This allows you to temporarily unmute your microphone by holding a button on your MIDI controller (studio style talkback).
For this, a second MIDI port needs to be assigned as Talkback MIDI input, which will listen for **Control Change** messages on **channel** **14**, **CC# 14**, values **0** and **127**.

With some clever MIDI routing, you could also configure your DAW to dim the audio output, thus creating a full studio style talkback experience.

Please note: talkback events will be ignored when the DAW is not playing (when this program considers the microphone unmuted), as it only makes sense to briefly defeat mute state while playing/recording (when local microphone is actually muted).

## Credits

Developed by [AtmanActive](https://github.com/AtmanActive/MIDI-Transport-to-Mute) by butchering the code from [MidiToMacro by Laurence Dougal Myers](https://github.com/laurence-myers/midi-to-macro), which was, in various forms, based on work by AHK forum members, including (in no particular order):

- genmce
- Orbik
- TomB
- Lazslo

Thanks to [William Wong](https://github.com/compulim), for his implementation of `OpenMidiInput`. (See [autohotkey-boss-fs-1-wl](https://github.com/compulim/autohotkey-boss-fs-1-wl)).
