#Requires AutoHotkey v2.0

; Callback from winmm.dll for any MIDI message
Fn_OnMidiData_1( hInput, midiMessage, * ) 
{
	global currentMidiInputDeviceIndex_1
	
	statusByte := midiMessage & 0xFF
	channel := (statusByte & 0x0F) + 1
	byte1 := (midiMessage >> 8) & 0xFF	; Note/CC number
	byte2 := (midiMessage >> 16) & 0xFF	; Note Velocity, or CC value

	description := ""
	if ( statusByte >= 128 and statusByte <= 143 ) 
	{
		description := "NoteOff"
	} 
	else if ( statusByte >= 144 and statusByte <= 159 ) 
	{
		description := "NoteOn"
	} 
	else if ( statusByte >= 176 and statusByte <= 191 ) 
	{
		description := "CC"
	} 
	else if ( statusByte >= 224 and statusByte <= 239 ) 
	{
		description := "PitchBend"
	}
	
	Fn_AppendMidiInputRow_1( description, statusByte, channel, byte1, byte2 )
	
	if ( statusByte >= 128 and statusByte <= 159 ) 
	{
		; Note off/on
		isNoteOn := ( statusByte >= 144 and byte2 > 0 )
		Fn_ProcessNote_1( currentMidiInputDeviceIndex_1, channel, byte1, byte2, isNoteOn )
	} 
	else if ( statusByte >= 176 and statusByte <= 191 ) 
	{ 
		; CC
		ProcessCC( currentMidiInputDeviceIndex_1, channel, byte1, byte2 )
	} 
	else if ( statusByte >= 192 and statusByte <= 208 ) 
	{ 
		; PC
		ProcessPC( currentMidiInputDeviceIndex_1, channel, byte1, byte2 )
	} 
	else if ( statusByte >= 224 and statusByte <= 239 ) 
	{ 
		; Pitch bend
		pitchBend := ( byte2 << 7 ) | byte1
		ProcessPitchBend( currentMidiInputDeviceIndex_1, channel, pitchBend )
	}

} ;;; END Fn_OnMidiData_1









; Callback from winmm.dll for any MIDI message
Fn_OnMidiData_2( hInput, midiMessage, * ) 
{
	global currentMidiInputDeviceIndex_2
	
	statusByte := midiMessage & 0xFF
	channel := (statusByte & 0x0F) + 1
	byte1 := (midiMessage >> 8) & 0xFF	; Note/CC number
	byte2 := (midiMessage >> 16) & 0xFF	; Note Velocity, or CC value

	description := ""
	if ( statusByte >= 128 and statusByte <= 143 ) 
	{
		description := "NoteOff"
	} 
	else if ( statusByte >= 144 and statusByte <= 159 ) 
	{
		description := "NoteOn"
	} 
	else if ( statusByte >= 176 and statusByte <= 191 ) 
	{
		description := "CC"
	} 
	else if ( statusByte >= 224 and statusByte <= 239 ) 
	{
		description := "PitchBend"
	}
	
	Fn_AppendMidiInputRow_2( description, statusByte, channel, byte1, byte2 )
	
	if ( statusByte >= 128 and statusByte <= 159 ) 
	{
		; Note off/on
		isNoteOn := ( statusByte >= 144 and byte2 > 0 )
		ProcessNote( currentMidiInputDeviceIndex_2, channel, byte1, byte2, isNoteOn )
	} 
	else if ( statusByte >= 176 and statusByte <= 191 ) 
	{ 
		; CC
		Fn_ProcessCC_2( currentMidiInputDeviceIndex_2, channel, byte1, byte2 )
	} 
	else if ( statusByte >= 192 and statusByte <= 208 ) 
	{ 
		; PC
		ProcessPC( currentMidiInputDeviceIndex_2, channel, byte1, byte2 )
	} 
	else if ( statusByte >= 224 and statusByte <= 239 ) 
	{ 
		; Pitch bend
		pitchBend := ( byte2 << 7 ) | byte1
		ProcessPitchBend( currentMidiInputDeviceIndex_2, channel, pitchBend )
	}

} ;;; END Fn_OnMidiData_2









; Callback for the MIDI input dropdown list
Fn_OnMidiInputChange_1( control, * )
{
	global currentMidiInputDeviceIndex_1, currentMidiInputDeviceIndex_2
	deviceIndex := control.Value - 1

	if ( IsSet( currentMidiInputDeviceIndex_2 ) and deviceIndex == currentMidiInputDeviceIndex_2 )
	{
		Fn_WarnDuplicateMidiPort()
		control.Value := IsSet( currentMidiInputDeviceIndex_1 ) ? currentMidiInputDeviceIndex_1 + 1 : 0
		return
	}

	Fn_OpenMidiInput_1( deviceIndex, Fn_OnMidiData_1 )
	deviceName := GetMidiDeviceName( deviceIndex )
	WriteConfigMidiDevice_1( deviceIndex, deviceName )
	Fn_AppendMidiOutputRow_1( "Device", deviceName )
	menuStatus.Rename( "1&", "Using MIDI device for Mute Signals: " deviceName )
}

Fn_OnMidiInputChange_2( control, * )
{
	global currentMidiInputDeviceIndex_1, currentMidiInputDeviceIndex_2
	deviceIndex := control.Value - 1

	if ( IsSet( currentMidiInputDeviceIndex_1 ) and deviceIndex == currentMidiInputDeviceIndex_1 )
	{
		Fn_WarnDuplicateMidiPort()
		control.Value := IsSet( currentMidiInputDeviceIndex_2 ) ? currentMidiInputDeviceIndex_2 + 1 : 0
		return
	}

	Fn_OpenMidiInput_2( deviceIndex, Fn_OnMidiData_2 )
	deviceName := GetMidiDeviceName( deviceIndex )
	WriteConfigMidiDevice_2( deviceIndex, deviceName )
	Fn_AppendMidiOutputRow_2( "Device", deviceName )
	menuStatus.Rename( "2&", "Using MIDI device for Talkback Signals: " deviceName )
}


ToggleShowOnStartup(*) 
{
	WriteConfigShowOnStartup( ! appConfig.showOnStartup )
	menuConfig.ToggleCheck( "Show MIDI Monitor on Startup" )
}
