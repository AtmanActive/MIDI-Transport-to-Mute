#Requires AutoHotkey v2

global appConfig

configFileName := "MIDI-Transport-to-Mute.ini"

Class MIDI_Transport_to_Mute_Config 
{
	__New() {
		this.maxLogLines := 10
		this.showOnStartup := true
		this.MIDI_input_Mackie_Mute_Number := -1
		this.MIDI_input_Mackie_Mute_Name := ""
		this.MIDI_input_Talkback_Hold_Number := -1
		this.MIDI_input_Talkback_Hold_Name := ""
	}
}

appConfig := MIDI_Transport_to_Mute_Config()

ReadConfig() 
{
	if ( FileExist( configFileName ) ) 
	{
		appConfig.maxLogLines                      := IniRead( configFileName, "Settings", "MaxLogLines", 10 )
		appConfig.showOnStartup                    := IniRead( configFileName, "Settings", "ShowOnStartup", true )
		appConfig.MIDI_input_Mackie_Mute_Number    := IniRead( configFileName, "Settings", "MIDI_input_Mackie_Mute_Number", -1 )
		appConfig.MIDI_input_Mackie_Mute_Name      := IniRead( configFileName, "Settings", "MIDI_input_Mackie_Mute_Name", "" )
		appConfig.MIDI_input_Talkback_Hold_Number  := IniRead( configFileName, "Settings", "MIDI_input_Talkback_Hold_Number", -1 )
		appConfig.MIDI_input_Talkback_Hold_Name    := IniRead( configFileName, "Settings", "MIDI_input_Talkback_Hold_Name", "" )
	}
}

WriteConfigMidiDevice_1( MIDI_input_Mackie_Mute_Number, MIDI_input_Mackie_Mute_Name ) 
{
	IniWrite( MIDI_input_Mackie_Mute_Number, configFileName, "Settings", "MIDI_input_Mackie_Mute_Number" )
	IniWrite( MIDI_input_Mackie_Mute_Name,   configFileName, "Settings", "MIDI_input_Mackie_Mute_Name" )
	appConfig.MIDI_input_Mackie_Mute_Number := MIDI_input_Mackie_Mute_Number
	appConfig.MIDI_input_Mackie_Mute_Name   := MIDI_input_Mackie_Mute_Name
}

WriteConfigMidiDevice_2( MIDI_input_Talkback_Hold_Number, MIDI_input_Talkback_Hold_Name ) 
{
	IniWrite( MIDI_input_Talkback_Hold_Number, configFileName, "Settings", "MIDI_input_Talkback_Hold_Number" )
	IniWrite( MIDI_input_Talkback_Hold_Name,   configFileName, "Settings", "MIDI_input_Talkback_Hold_Name" )
	appConfig.MIDI_input_Talkback_Hold_Number := MIDI_input_Talkback_Hold_Number
	appConfig.MIDI_input_Talkback_Hold_Name   := MIDI_input_Talkback_Hold_Name
}

WriteConfigShowOnStartup( showOnStartup ) 
{
	IniWrite( showOnStartup, configFileName, "Settings", "ShowOnStartup" )
	appConfig.showOnStartup := showOnStartup
}
