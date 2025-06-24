#Requires AutoHotkey v2

global currentMidiInputDeviceHandle_1, currentMidiInputDeviceIndex_1, currentMidiInputDeviceHandle_2, currentMidiInputDeviceIndex_2


Fn_CloseMidiInputs(*)
{
	Fn_CloseMidiInput_1()
	Fn_CloseMidiInput_2()
}

Fn_CloseMidiInput_1(*) 
{
	global currentMidiInputDeviceHandle_1, currentMidiInputDeviceIndex_1

	if ( IsSet( currentMidiInputDeviceHandle_1 ) ) 
	{
		DllCall( "winmm.dll\midiInReset", "UInt", currentMidiInputDeviceHandle_1 )
		DllCall( "winmm.dll\midiInClose", "UInt", currentMidiInputDeviceHandle_1 )
	}
	
	currentMidiInputDeviceHandle_1 := unset
	currentMidiInputDeviceIndex_1 := unset
}

Fn_CloseMidiInput_2(*) 
{
	global currentMidiInputDeviceHandle_2, currentMidiInputDeviceIndex_2

	if ( IsSet( currentMidiInputDeviceHandle_2 ) ) 
	{
		DllCall( "winmm.dll\midiInReset", "UInt", currentMidiInputDeviceHandle_2 )
		DllCall( "winmm.dll\midiInClose", "UInt", currentMidiInputDeviceHandle_2 )
	}
	
	currentMidiInputDeviceHandle_2 := unset
	currentMidiInputDeviceIndex_2 := unset
}



GetMidiDeviceName( deviceIndex ) 
{
	
	; TODO: should we be calling the ANSI version directly, or let AHK decide on W vs A?
	; TODO: should we be parsing the port name in UTF-8, or is it some other encoding?
	midiInCapabilitiesSize := 50
	midiInCapabilities := Buffer( midiInCapabilitiesSize )
	result := DllCall( "winmm.dll\midiInGetDevCapsA", "UInt", deviceIndex, "Ptr", midiInCapabilities, "UInt", midiInCapabilitiesSize, "UInt" )
	; result > 0 is an error
	If ( result ) 
	{
		return
	}
	
	; Copy the device name out of the capabilities binary struct
	portName := StrGet( midiInCapabilities.Ptr + 8, "UTF-8" )
	return portName
	
} ;;; END GetMidiDeviceName()




Fn_LoadMidiInputs() 
{
	
	midiInputs := Array()
	numPorts := DllCall( "winmm.dll\midiInGetNumDevs" )
	
	Loop numPorts 
	{
		
		portName := GetMidiDeviceName( A_Index - 1 )
		
		if ( portName ) 
		{
			midiInputs.Push( portName )
		}
		
	}
	
	return midiInputs
	
} ;;; END Fn_LoadMidiInputs()




Fn_OpenMidiInput_1( midiInputDeviceIndex, onMidiMessageCallback ) 
{
	
	global currentMidiInputDeviceHandle_1, currentMidiInputDeviceIndex_1
	
	Fn_CloseMidiInput_1()
	
	CALLBACK_WINDOW := 0x10000
	hMidiIn := Buffer(8)
	result := DllCall( "winmm.dll\midiInOpen", "Ptr", hMidiIn, "UInt", midiInputDeviceIndex, "UInt", A_ScriptHwnd, "UInt", 0, "UInt", CALLBACK_WINDOW, "UInt" )
	
	if ( result ) 
	{
		MsgBox( "Failed to call midiInOpen for device ID " . midiInputDeviceIndex )
		Return
	}
	
	currentMidiInputDeviceHandle_1 := NumGet( hMidiIn, 0, "UInt" )
	result := DllCall( "winmm.dll\midiInStart", "UInt", currentMidiInputDeviceHandle_1, "UInt" )
	
	if ( result ) 
	{
		MsgBox( "Failed to call midiInStart for device ID " . midiInputDeviceIndex )
		Return
	}
	
	OnMessage( 0x3C3, onMidiMessageCallback ) ; MM_MIM_DATA, https://learn.microsoft.com/en-us/windows/win32/multimedia/mm-mim-data
	
	currentMidiInputDeviceIndex_1 := midiInputDeviceIndex
	
} ;;; END Fn_OpenMidiInput_1()





Fn_OpenMidiInput_2( midiInputDeviceIndex, onMidiMessageCallback ) 
{
	
	global currentMidiInputDeviceHandle_2, currentMidiInputDeviceIndex_2
	
	Fn_CloseMidiInput_2()
	
	CALLBACK_WINDOW := 0x10000
	hMidiIn := Buffer(8)
	result := DllCall( "winmm.dll\midiInOpen", "Ptr", hMidiIn, "UInt", midiInputDeviceIndex, "UInt", A_ScriptHwnd, "UInt", 0, "UInt", CALLBACK_WINDOW, "UInt" )
	
	if ( result ) 
	{
		MsgBox( "Failed to call midiInOpen for device ID " . midiInputDeviceIndex )
		Return
	}
	
	currentMidiInputDeviceHandle_2 := NumGet( hMidiIn, 0, "UInt" )
	result := DllCall( "winmm.dll\midiInStart", "UInt", currentMidiInputDeviceHandle_2, "UInt" )
	
	if ( result ) 
	{
		MsgBox( "Failed to call midiInStart for device ID " . midiInputDeviceIndex )
		Return
	}
	
	OnMessage( 0x3C3, onMidiMessageCallback ) ; MM_MIM_DATA, https://learn.microsoft.com/en-us/windows/win32/multimedia/mm-mim-data
	
	currentMidiInputDeviceIndex_2 := midiInputDeviceIndex
	
} ;;; END Fn_OpenMidiInput_2()
