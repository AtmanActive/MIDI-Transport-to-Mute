#Requires AutoHotkey v2

;*************************************************
;*          RULES - MIDI FILTERS
;*************************************************

/* 
	The MidiRules section is for mapping MIDI input to actions.
	Alter these functions as required.
*/


Fn_ProcessNote_1( device, channel, note, velocity, isNoteOn ) 
{
	
	if ( channel = 1 and note = 93 and velocity = 127 )
	{
		Fn_PerformSoundInputUnMute()
	}
	
	if ( channel = 1 and note = 94 and velocity = 127 )
	{
		Fn_PerformSoundInputMute()
	}
	
}



Fn_PerformSoundInputMute()
{
	global is_muted_by_mackie_now
	SoundSetMute 1, "", "MicInput"
	Fn_DisplayOutput_1( "MicInput", "Muted" )
	TraySetIcon "icon_red.ico"
	A_IconTip := "MIDI-Transport-to-Mute muted"
	is_muted_by_mackie_now := true
	menuTest.Enable( "Engage Talkback now" )
	menuTest.Enable( "Disengage Talkback now" )
}

Fn_PerformSoundInputUnMute()
{
	global is_muted_by_mackie_now
	SoundSetMute 0, "", "MicInput"
	Fn_DisplayOutput_1( "MicInput", "Unmuted" )
	TraySetIcon "icon_green.ico"
	A_IconTip := "MIDI-Transport-to-Mute unmuted"
	is_muted_by_mackie_now := false
	menuTest.Disable( "Engage Talkback now" )
	menuTest.Disable( "Disengage Talkback now" )
}
