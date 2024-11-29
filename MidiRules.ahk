#Requires AutoHotkey v2

;*************************************************
;*          RULES - MIDI FILTERS
;*************************************************

/* 
	The MidiRules section is for mapping MIDI input to actions.
	Alter these functions as required.
*/


ProcessNote( device, channel, note, velocity, isNoteOn ) 
{
	
	if ( channel = 1 and note = 93 and velocity = 127 )
	{
		PerformSoundInputUnMute()
	}
	
	if ( channel = 1 and note = 94 and velocity = 127 )
	{
		PerformSoundInputMute()
	}
	
}

ProcessCC( device, channel, cc, value ) 
{

}

ProcessPC( device, channel, note, velocity ) 
{
	
}

ProcessPitchBend( device, channel, value ) 
{
	
}

PerformSoundInputMute()
{
	SoundSetMute 1, "", "MicInput"
	DisplayOutput( "MicInput", "Muted" )
	TraySetIcon "icon_red.ico"
	A_IconTip := "MIDI-Transport-to-Mute muted"
}

PerformSoundInputUnMute()
{
	SoundSetMute 0, "", "MicInput"
	DisplayOutput( "MicInput", "Unmuted" )
	TraySetIcon "icon_green.ico"
	A_IconTip := "MIDI-Transport-to-Mute unmuted"
}
