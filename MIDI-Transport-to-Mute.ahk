#Requires AutoHotkey v2
#SingleInstance
#Warn
Persistent()

#Include lib\Config.ahk
#Include lib\Gui.ahk

MaybeOpenMidiInput() {
	global appConfig, currentMidiInputDeviceIndex

	if (
		appConfig.midiInDevice >= 0
		; Open the MIDI input, if we don't have a "device name" stored, or if
		; the stored device name matches the actual device name
		and (
			StrLen(appConfig.midiInDeviceName) == 0
			or GetMidiDeviceName(appConfig.midiInDevice) == appConfig.midiInDeviceName
		)
	) {
		OpenMidiInput(appConfig.midiInDevice, OnMidiData)
		A_IconTip := "MIDI-Transport-to-Mute listening on MIDI device: " . GetMidiDeviceName( appConfig.midiInDevice )
		return true
	}
	return false
}

DummyNonExistentFunction(*) 
{
	return false
}

Main() {
	global appConfig, currentMidiInputDeviceIndex
	OnExit(CloseMidiInput)
	
	TraySetIcon "icon.ico"
	A_IconTip := "MIDI-Transport-to-Mute"
	
	A_TrayMenu.Add() ; Add a menu separator line
	A_TrayMenu.Add("Show on Startup", ToggleShowOnStartup)
	A_TrayMenu.Add("MIDI Monitor", ShowMidiMonitor)
	A_TrayMenu.Add( "Rename your default audio input device to MicInput", DummyNonExistentFunction )
	A_TrayMenu.Disable( "Rename your default audio input device to MicInput" )
	ReadConfig()
	wasMidiOpened := MaybeOpenMidiInput()
	if (appConfig.showOnStartup) {
		A_TrayMenu.Check("Show on Startup")
	} else {
		A_TrayMenu.Uncheck("Show on Startup")
	}

	if (!wasMidiOpened || appConfig.showOnStartup) {
		ShowMidiMonitor()
	}
}

Main()
