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

Main() 
{
	global appConfig, currentMidiInputDeviceIndex
	
	OnExit( CloseMidiInput )
	
	TraySetIcon "icon.ico"
	
	programName := "MIDI-Transport-to-Mute v1.1.0"
	
	A_IconTip := programName
	
	; Remove all standard menu items
	A_TrayMenu.Delete()
	
	A_TrayMenu.Add( programName, MenuHandlerTitle )
	A_TrayMenu.Disable( programName )
	A_TrayMenu.Add() ; Add a menu separator line
	
	A_TrayMenu.Add() ; Add a menu separator line
	A_TrayMenu.Add( "Open MIDI Monitor", ShowMidiMonitor )
	A_TrayMenu.Add( "Show MIDI Monitor on Startup", ToggleShowOnStartup )
	
	A_TrayMenu.Add() ; Add a menu separator line
	A_TrayMenu.Add( "Rename your default audio input device to MicInput", MenuHandlerMicRename )
	
	A_TrayMenu.Add()  ; Creates a separator line.
	A_TrayMenu.Add( "Mute Microphone now", MenuHandlerMuteNow )
	A_TrayMenu.Add( "Unmute Microphone now", MenuHandlerUnMuteNow )
	
	A_TrayMenu.Add()  ; Creates a separator line.
	A_TrayMenu.Add( "About", MenuHandlerAbout )
	
	A_TrayMenu.Add()  ; Creates a separator line.
	A_TrayMenu.Add( "Exit", MenuHandlerExit )
	
	ReadConfig()
	wasMidiOpened := MaybeOpenMidiInput()
	
	if ( appConfig.showOnStartup ) 
	{
		A_TrayMenu.Check( "Show MIDI Monitor on Startup" )
	} 
	else 
	{
		A_TrayMenu.Uncheck( "Show MIDI Monitor on Startup" )
	}

	if ( ! wasMidiOpened || appConfig.showOnStartup ) 
	{
		ShowMidiMonitor()
	}
	
	MenuHandlerTitle( ItemName, ItemPos, MyMenu )
	{
		
	}
	
	MenuHandlerAbout( ItemName, ItemPos, MyMenu ) 
	{
		Result := MsgBox( programName "`n`n`n`nThe purpose of this program is to mute/unmute the windows audio input named MicInput according to incoming MIDI signals for Mackie Stop and Play (A6 & A#6)[093 & 094]{0x5D & 0x5E}. `n`nThis is useful in an online music recording studio session where all participants can be muted on DAW play and unmuted on DAW stop.`n`nDeveloped by AtmanActive, 2024. `n`n`n`nWould you like to open the home page?",, "YesNo")
		if ( Result = "Yes" )
		{
			Run( "https://github.com/AtmanActive/MIDI-Transport-to-Mute" )
		}
	}
	
	
	MenuHandlerMicRename( ItemName, ItemPos, MyMenu )
	{
		Result := MsgBox( programName "`n`n`n`nThis program expects an audio input device to be titled 'MicInput' in order to be able to control the muted state. Just rename your desired audio input to 'MicInput' in your windows sound control panel.`n`n`n`nWould you like to open the windows sound control panel (takes several seconds to show up)?",, "YesNo")
		if ( Result = "Yes" )
		{
			Run( "mmsys.cpl" )
		}
	}
	
	
	
	MenuHandlerExit( ItemName, ItemPos, MyMenu ) 
	{
		ExitApp 0
	}
	
	MenuHandlerMuteNow( ItemName, ItemPos, MyMenu ) 
	{
		PerformSoundInputMute()
	}
	
	MenuHandlerUnMuteNow( ItemName, ItemPos, MyMenu ) 
	{
		PerformSoundInputUnMute()
	}
	
}

Main()
