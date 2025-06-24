#Requires AutoHotkey v2
#include CommonFunctions.ahk
#include MidiLib.ahk
#include MidiRulesExecMute.ahk
#include MidiRulesExecTalkback.ahk
#include MidiRulesEmpty.ahk
#include EventHandlers.ahk

global lvInEvents_1, lvOutEvents_1, lvInEvents_2, lvOutEvents_2, midiMonitor_1, midiMonitor_2



; Adds a row to the MIDI input log
Fn_AppendMidiInputRow_1( description, statusByte, channel, byte1, byte2 ) 
{
	if ( ! IsSet( midiMonitor_1 ) ) 
	{
		return
	}
	global lvInEvents_1
	AppendRow( lvInEvents_1, description, statusByte, channel, byte1, byte2 )
}

Fn_AppendMidiInputRow_2( description, statusByte, channel, byte1, byte2 ) 
{
	if ( ! IsSet( midiMonitor_2 ) ) 
	{
		return
	}
	global lvInEvents_2
	AppendRow( lvInEvents_2, description, statusByte, channel, byte1, byte2 )
}








; Adds a row to the MIDI output log
Fn_AppendMidiOutputRow_1( description, value ) 
{
	if ( ! IsSet( midiMonitor_1 ) ) 
	{
		return
	}
	global lvOutEvents_1
	AppendRow( lvOutEvents_1, description, value )
}


Fn_AppendMidiOutputRow_2( description, value ) 
{
	if ( ! IsSet( midiMonitor_2 ) ) 
	{
		return
	}
	global lvOutEvents_2
	AppendRow( lvOutEvents_2, description, value )
}




; Generic base function to append a row to a list view
AppendRow( listView, values* ) 
{
	global appConfig
	listView.Add( "", values* )
	if ( listView.GetCount() > appConfig.maxLogLines ) 
	{
		listView.Delete(1)
	}
}





; Alias, for backwards compatibility

Fn_DisplayOutput_1( event, value ) 
{
	Fn_AppendMidiOutputRow_1( event, value )
}

Fn_DisplayOutput_2( event, value ) 
{
	Fn_AppendMidiOutputRow_2( event, value )
}





; Entry point
Fn_ShowMidiMonitor_1(*) 
{
	global lvInEvents_1, lvOutEvents_1, midiMonitor_1

	if ( IsSet( midiMonitor_1 ) ) 
	{
		midiMonitor_1.Show()
		return
	}

	midiInputOptions := Fn_LoadMidiInputs()
	; Init GUI
	midiMonitor_1 := Gui(, "MIDI-Transport-to-Mute Monitor for Mute Events")
	; Label and dropdown
	midiMonitor_1.Add( "Text", "X80 Y5", "MIDI Input" )
	midiMonitor_1.Add( "Text", "X265 Y22", "Rename your default audio input device to MicInput" )
	ddlMidiInput := midiMonitor_1.Add( "DropDownList", "X40 Y20 W200", midiInputOptions )

	if ( IsSet( currentMidiInputDeviceIndex_1 ) ) 
	{
		ddlMidiInput.Value := currentMidiInputDeviceIndex_1 + 1
	}
	ddlMidiInput.OnEvent( "Change", Fn_OnMidiInputChange_1 )
	; List views
	listViewStyle := "W320 R11 BackgroundBlack Count10"
	; List view - MIDI input
	lvInEvents_1 := midiMonitor_1.Add( "ListView", listViewStyle . " " . "X5 cAqua", [ "EventType", "StatB", "Ch", "Byte1", "Byte2" ] )
	Loop lvInEvents_1.GetCount( "Column" ) 
	{
		lvInEvents_1.ModifyCol( A_Index, "Center" )
	}
	; List view - output
	lvOutEvents_1 := midiMonitor_1.Add( "ListView", listViewStyle . " " . "X+5 cYellow", [ "Event", "Value" ] )
	Loop lvOutEvents_1.GetCount( "Column" ) 
	{
		lvOutEvents_1.ModifyCol( A_Index, "Center" )
	}
	; Set column sizes for the output list view
	lvOutEvents_1.ModifyCol( 1, 105 )
	lvOutEvents_1.ModifyCol( 2, 110 )
	; Show the GUI
	midiMonitor_1.Show( "AutoSize xCenter Y5" )

} ;;; END Fn_ShowMidiMonitor_1








; Entry point
Fn_ShowMidiMonitor_2(*) 
{
	global lvInEvents_2, lvOutEvents_2, midiMonitor_2

	if ( IsSet( midiMonitor_2 ) ) 
	{
		midiMonitor_2.Show()
		return
	}

	midiInputOptions := Fn_LoadMidiInputs()
	; Init GUI
	midiMonitor_2 := Gui(, "MIDI-Transport-to-Mute Monitor for Talkback Events")
	; Label and dropdown
	midiMonitor_2.Add( "Text", "X80 Y5", "MIDI Input" )
	midiMonitor_2.Add( "Text", "X265 Y22", "Rename your default audio input device to MicInput" )
	ddlMidiInput := midiMonitor_2.Add( "DropDownList", "X40 Y20 W200", midiInputOptions )

	if ( IsSet( currentMidiInputDeviceIndex_2 ) ) 
	{
		ddlMidiInput.Value := currentMidiInputDeviceIndex_2 + 1
	}
	ddlMidiInput.OnEvent( "Change", Fn_OnMidiInputChange_2 )
	; List views
	listViewStyle := "W320 R11 BackgroundBlack Count10"
	; List view - MIDI input
	lvInEvents_2 := midiMonitor_2.Add( "ListView", listViewStyle . " " . "X5 cAqua", [ "EventType", "StatB", "Ch", "Byte1", "Byte2" ] )
	Loop lvInEvents_2.GetCount( "Column" ) 
	{
		lvInEvents_2.ModifyCol( A_Index, "Center" )
	}
	; List view - output
	lvOutEvents_2 := midiMonitor_2.Add( "ListView", listViewStyle . " " . "X+5 cYellow", [ "Event", "Value" ] )
	Loop lvOutEvents_2.GetCount( "Column" ) 
	{
		lvOutEvents_2.ModifyCol( A_Index, "Center" )
	}
	; Set column sizes for the output list view
	lvOutEvents_2.ModifyCol( 1, 105 )
	lvOutEvents_2.ModifyCol( 2, 110 )
	; Show the GUI
	midiMonitor_2.Show( "AutoSize xCenter Y5" )

} ;;; END Fn_ShowMidiMonitor_2



