#Requires AutoHotkey v2

;*************************************************
;*          RULES - MIDI FILTERS
;*************************************************

/* 
	The MidiRules section is for mapping MIDI input to actions.
	Alter these functions as required.
*/




Fn_ProcessCC_2( device, channel, cc, value ) 
{

	if ( channel = 14 and cc = 14 and value = 127 )
	{
		Fn_PerformTalkback_Engage()
	}

	if ( channel = 14 and cc = 14 and value = 0 )
	{
		Fn_PerformTalkback_Disengage()
	}

}



Fn_PerformTalkback_Disengage()
{
	
	global is_muted_by_mackie_now
	
	if ( is_muted_by_mackie_now = true )
	{
		SoundSetMute 1, "", "MicInput"
		Fn_DisplayOutput_2( "MicInput", "Talkback Off" )
		TraySetIcon "icon_red.ico"
		A_IconTip := "MIDI-Transport-to-Mute muted"
	}
	else
	{
		Fn_DisplayOutput_2( "MicInput", "Not muted" )
	}
	
} ;;; END Fn_PerformTalkback_Disengage()

Fn_PerformTalkback_Engage()
{
	
	global is_muted_by_mackie_now
	
	if ( is_muted_by_mackie_now = true )
	{
		SoundSetMute 0, "", "MicInput"
		Fn_DisplayOutput_2( "MicInput", "Talkback On" )
		TraySetIcon "icon_purple.ico"
		A_IconTip := "MIDI-Transport-to-Mute unmuted"
	}
	else
	{
		Fn_DisplayOutput_2( "MicInput", "Not muted" )
	}

} ;;; END Fn_PerformTalkback_Engage()



