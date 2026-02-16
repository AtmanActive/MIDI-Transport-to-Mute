#Requires AutoHotkey v2
#SingleInstance
#Warn
Persistent()

#Include lib\Config.ahk
#Include lib\Gui.ahk

; The program controls microphone mute states using incoming MIDI signals.
; Includes features to show/hide the MIDI monitor and configure startup behavior.

; v2.0.2


global is_muted_by_mackie_now := false


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
	A_TrayMenu.Rename( "3&", "Using MIDI device for Mute Signals: " GetMidiDeviceName( resolvedIndex ) )
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
	A_TrayMenu.Rename( "4&", "Using MIDI device for Talkback Signals: " GetMidiDeviceName( resolvedIndex ) )
	return true

} ;;; END Fn_MaybeOpenMidiInput_2()







DummyNonExistentFunction(*) 
{
	return false
}

Main() 
{
	global appConfig, currentMidiInputDeviceIndex_1, currentMidiInputDeviceIndex_2
	
	OnExit( Fn_CloseMidiInputs )
	
	TraySetIcon "icon.ico"
	
	programName := "MIDI-Transport-to-Mute v2.0.2"
	
	A_IconTip := programName
	
	; Remove all standard menu items
	A_TrayMenu.Delete()
	
	A_TrayMenu.Add( programName, MenuHandlerTitle ) ; 1
	A_TrayMenu.Disable( programName )
	A_TrayMenu.Add() ; Add a menu separator line - 2
	
	A_TrayMenu.Add( "MIDI Port for Mute Signals", MenuHandlerTitle ) ; 3
	A_TrayMenu.Disable( "3&" )
	A_TrayMenu.Add( "MIDI Port for Talkback Signals", MenuHandlerTitle ) ; 4
	A_TrayMenu.Disable( "4&" )
	A_TrayMenu.Add( "Using audio input: MicInput", MenuHandlerTitle ) ; 5
	A_TrayMenu.Disable( "5&" )
	A_TrayMenu.Add() ; Add a menu separator line - 6
	
	A_TrayMenu.Add() ; Add a menu separator line - 7
	A_TrayMenu.Add( "Open MIDI Monitor for Mute Signals MIDI Port", Fn_ShowMidiMonitor_1 ) ; 8
	A_TrayMenu.Add( "Open MIDI Monitor for Talkback Signals MIDI Port", Fn_ShowMidiMonitor_2 ) ; 9
	A_TrayMenu.Add( "Show MIDI Monitor on Startup", ToggleShowOnStartup ) ; 10
	
	A_TrayMenu.Add() ; Add a menu separator line - 11
	A_TrayMenu.Add( "Rename your default audio input device to MicInput", MenuHandlerMicRename ) ; 12
	
	A_TrayMenu.Add()  ; Creates a separator line - 13
	A_TrayMenu.Add( "Mute Microphone now", MenuHandlerMuteNow ) ; 14
	A_TrayMenu.Add( "Unmute Microphone now", MenuHandlerUnMuteNow ) ; 15
	
	A_TrayMenu.Add()  ; Creates a separator line - 16
	A_TrayMenu.Add( "Engage Talkback now", MenuHandlerTalkbackOnNow ) ; 17
	A_TrayMenu.Add( "Disengage Talkback now", MenuHandlerTalkbackOffNow ) ; 18
	A_TrayMenu.Disable( "17&" )
	A_TrayMenu.Disable( "18&" )
	
	A_TrayMenu.Add()  ; Creates a separator line - 19
	A_TrayMenu.Add( "About", MenuHandlerAbout ) ; 20
	
	A_TrayMenu.Add()  ; Creates a separator line - 21
	A_TrayMenu.Add( "Exit", MenuHandlerExit ) ; 22
	
	ReadConfig()
	wasMidiOpened_1 := Fn_MaybeOpenMidiInput_1()
	wasMidiOpened_2 := Fn_MaybeOpenMidiInput_2()
	
	if ( appConfig.showOnStartup ) 
	{
		A_TrayMenu.Check( "Show MIDI Monitor on Startup" )
	} 
	else 
	{
		A_TrayMenu.Uncheck( "Show MIDI Monitor on Startup" )
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
		Result := MsgBox( programName "`n`n`n`nThe purpose of this program is to mute/unmute the windows audio input named MicInput according to incoming MIDI signals for Mackie Stop and Play (A6 & A#6)[093 & 094]{0x5D & 0x5E}. In addition, a second MIDI port can be used for Talkback events via CC#14 on channel 14, values 0 and 127.  `n`nThis is useful in an online music recording studio session where all participants can be muted on DAW play and unmuted on DAW stop.`n`nDeveloped by AtmanActive, 2024, 2025. `n`n`n`nWould you like to open the home page?",, "YesNo")
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
