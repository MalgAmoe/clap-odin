package ext_draft

import clap "../.."

// This extension lets the host add and remove audio ports to the plugin.
EXT_EXTENSIBLE_AUDIO_PORTS :: "clap.extensible-audio-ports/1"

Plugin_Extensible_Audio_Ports :: struct {
	// Asks the plugin to add a new port (at the end of the list), with the following settings.
	// port_type: see Audio_Port_Info.port_type for interpretation.
	// port_details: see Audio_Port_Configuration_Request.port_details for interpretation.
	// Returns true on success.
	// [main-thread && !is_active]
	add_port:    proc "c" (
		plugin: ^clap.Plugin,
		is_input: bool,
		channel_count: u32,
		port_type: cstring,
		port_details: rawptr,
	) -> bool,

	// Asks the plugin to remove a port.
	// Returns true on success.
	// [main-thread && !is_active]
	remove_port: proc "c" (plugin: ^clap.Plugin, is_input: bool, index: u32) -> bool,
}
