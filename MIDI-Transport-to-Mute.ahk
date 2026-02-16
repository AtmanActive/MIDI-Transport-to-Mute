#Requires AutoHotkey v2
#SingleInstance
#Warn
Persistent()

#Include lib\Config.ahk
#Include lib\Gui.ahk

; The program controls microphone mute states using incoming MIDI signals.
; Includes features to show/hide the MIDI monitor and configure startup behavior.

; v2.0.3


global is_muted_by_mackie_now := false
global menuStatus, menuConfig, menuTest


Fn_MaybeOpenMidiInput_1()
{

	global appConfig, currentMidiInputDeviceIndex_1, currentMidiInputDeviceIndex_2

	if ( appConfig.MIDI_input_Mackie_Mute_Number < 0 )
	{
		return false
	}

	resolvedIndex := appConfig.MIDI_input_Mackie_Mute_Number

	; If we have a stored name, verify it still matches the device at the saved index
	if ( StrLen( appConfig.MIDI_input_Mackie_Mute_Name ) > 0
		and GetMidiDeviceName( resolvedIndex ) !== appConfig.MIDI_input_Mackie_Mute_Name )
	{
		; Name mismatch — Windows re-enumerated ports. Search by name.
		resolvedIndex := FindMidiInputIndexByName( appConfig.MIDI_input_Mackie_Mute_Name )

		if ( resolvedIndex < 0 )
		{
			return false
		}

		; Update the INI with the new index so next startup is fast
		WriteConfigMidiDevice_1( resolvedIndex, appConfig.MIDI_input_Mackie_Mute_Name )
	}

	; Prevent opening the same port already used by the other input
	if ( IsSet( currentMidiInputDeviceIndex_2 ) and resolvedIndex == currentMidiInputDeviceIndex_2 )
	{
		Fn_WarnDuplicateMidiPort()
		return false
	}

	Fn_OpenMidiInput_1( resolvedIndex, Fn_OnMidiData_1 )
	A_IconTip := "MIDI-Transport-to-Mute, input audio device MicInput, listening on MIDI device: " . GetMidiDeviceName( resolvedIndex )
	menuStatus.Rename( "1&", "Using MIDI device for Mute Signals: " GetMidiDeviceName( resolvedIndex ) )
	return true

} ;;; END Fn_MaybeOpenMidiInput_1()





Fn_MaybeOpenMidiInput_2()
{

	global appConfig, currentMidiInputDeviceIndex_2, currentMidiInputDeviceIndex_2

	if ( appConfig.MIDI_input_Talkback_Hold_Number < 0 )
	{
		return false
	}

	resolvedIndex := appConfig.MIDI_input_Talkback_Hold_Number

	; If we have a stored name, verify it still matches the device at the saved index
	if ( StrLen( appConfig.MIDI_input_Talkback_Hold_Name ) > 0
		and GetMidiDeviceName( resolvedIndex ) !== appConfig.MIDI_input_Talkback_Hold_Name )
	{
		; Name mismatch — Windows re-enumerated ports. Search by name.
		resolvedIndex := FindMidiInputIndexByName( appConfig.MIDI_input_Talkback_Hold_Name )

		if ( resolvedIndex < 0 )
		{
			return false
		}

		; Update the INI with the new index so next startup is fast
		WriteConfigMidiDevice_2( resolvedIndex, appConfig.MIDI_input_Talkback_Hold_Name )
	}

	; Prevent opening the same port already used by the other input
	if ( IsSet( currentMidiInputDeviceIndex_1 ) and resolvedIndex == currentMidiInputDeviceIndex_1 )
	{
		Fn_WarnDuplicateMidiPort()
		return false
	}

	Fn_OpenMidiInput_2( resolvedIndex, Fn_OnMidiData_2 )
	A_IconTip := "MIDI-Transport-to-Mute, input audio device MicInput, listening on MIDI device: " . GetMidiDeviceName( resolvedIndex )
	menuStatus.Rename( "2&", "Using MIDI device for Talkback Signals: " GetMidiDeviceName( resolvedIndex ) )
	return true

} ;;; END Fn_MaybeOpenMidiInput_2()







DummyNonExistentFunction(*) 
{
	return false
}

Main() 
{
	global appConfig, currentMidiInputDeviceIndex_1, currentMidiInputDeviceIndex_2, menuStatus, menuConfig, menuTest

	OnExit( Fn_CloseMidiInputs )
	
	TraySetIcon "icon.ico"
	
	programName := "MIDI-Transport-to-Mute v2.0.3"
	
	A_IconTip := programName
	
	; Remove all standard menu items
	A_TrayMenu.Delete()

	; Status submenu — informational items
	menuStatus := Menu()
	menuStatus.Add( "MIDI Port for Mute Signals", MenuHandlerTitle )
	menuStatus.Disable( "MIDI Port for Mute Signals" )
	menuStatus.Add( "MIDI Port for Talkback Signals", MenuHandlerTitle )
	menuStatus.Disable( "MIDI Port for Talkback Signals" )
	menuStatus.Add( "Using audio input: MicInput", MenuHandlerTitle )
	menuStatus.Disable( "Using audio input: MicInput" )

	; Config submenu — monitors and settings
	menuConfig := Menu()
	menuConfig.Add( "Open MIDI Monitor for Mute Signals MIDI Port", Fn_ShowMidiMonitor_1 )
	menuConfig.Add( "Open MIDI Monitor for Talkback Signals MIDI Port", Fn_ShowMidiMonitor_2 )
	menuConfig.Add( "Show MIDI Monitor on Startup", ToggleShowOnStartup )
	menuConfig.Add()
	menuConfig.Add( "Rename your default audio input device to MicInput", MenuHandlerMicRename )

	; Test submenu — manual mute/talkback actions
	menuTest := Menu()
	menuTest.Add( "Mute Microphone now", MenuHandlerMuteNow )
	menuTest.Add( "Unmute Microphone now", MenuHandlerUnMuteNow )
	menuTest.Add()
	menuTest.Add( "Engage Talkback now", MenuHandlerTalkbackOnNow )
	menuTest.Add( "Disengage Talkback now", MenuHandlerTalkbackOffNow )
	menuTest.Disable( "Engage Talkback now" )
	menuTest.Disable( "Disengage Talkback now" )

	; Top-level tray menu
	A_TrayMenu.Add( programName, MenuHandlerTitle )
	A_TrayMenu.Disable( programName )
	A_TrayMenu.Add()
	A_TrayMenu.Add( "Status", menuStatus )
	A_TrayMenu.Add( "Config", menuConfig )
	A_TrayMenu.Add( "Test", menuTest )
	A_TrayMenu.Add()
	A_TrayMenu.Add( "About", MenuHandlerAbout )
	A_TrayMenu.Add()
	A_TrayMenu.Add( "Exit", MenuHandlerExit )
	
	ReadConfig()
	wasMidiOpened_1 := Fn_MaybeOpenMidiInput_1()
	wasMidiOpened_2 := Fn_MaybeOpenMidiInput_2()
	
	if ( appConfig.showOnStartup ) 
	{
		menuConfig.Check( "Show MIDI Monitor on Startup" )
	} 
	else 
	{
		menuConfig.Uncheck( "Show MIDI Monitor on Startup" )
	}

	if ( ! wasMidiOpened_1 || appConfig.showOnStartup ) 
	{
		Fn_ShowMidiMonitor_1()
	}
	
	if ( ! wasMidiOpened_2 || appConfig.showOnStartup ) 
	{
		Fn_ShowMidiMonitor_2()
	}
	
	MenuHandlerTitle( ItemName, ItemPos, MyMenu )
	{
		
	}
	
	MenuHandlerAbout( ItemName, ItemPos, MyMenu ) 
	{
		Result := MsgBox( programName "`n`n`n`nThe purpose of this program is to mute/unmute the windows audio input named MicInput according to incoming MIDI signals for Mackie Stop and Play (A6 & A#6)[093 & 094]{0x5D & 0x5E}. In addition, a second MIDI port can be used for Talkback events via CC#14 on channel 14, values 0 and 127.  `n`nThis is useful in an online music recording studio session where all participants can be muted on DAW play and unmuted on DAW stop.`n`nDeveloped by AtmanActive, 2024, 2025, 2026. `n`n`n`nWould you like to open the home page?",, "YesNo")
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
		Fn_PerformSoundInputMute()
	}
	
	MenuHandlerUnMuteNow( ItemName, ItemPos, MyMenu ) 
	{
		Fn_PerformSoundInputUnMute()
	}
	
	MenuHandlerTalkbackOnNow( ItemName, ItemPos, MyMenu ) 
	{
		Fn_PerformTalkback_Engage()
	}
	
	MenuHandlerTalkbackOffNow( ItemName, ItemPos, MyMenu ) 
	{
		Fn_PerformTalkback_Disengage()
	}
	
}

Main()
