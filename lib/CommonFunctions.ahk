#Requires AutoHotkey v2

Fn_WarnDuplicateMidiPort()
{
	MsgBox( "The selected MIDI port is already in use by the other MIDI input. Please select distinct ports for Mute and Talkback signals. They can not be the same port." )
}

ConvertCCValueToScale(value, minimum_value, maximum_value) {
	if (value > maximum_value) {
		value := maximum_value
	} else if (value < minimum_value) {
		value := minimum_value
	}
	return (value - minimum_value) / (maximum_value - minimum_value)
}
