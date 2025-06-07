package ext

import clap "../../clap-odin"

//////////////////////
// Configurable Audio Ports //
//////////////////////
// This extension lets the host configure the plugin's input and output audio ports.
// This is a "push" approach to audio ports configuration.

// Configurable audio ports extension identifier  
EXT_CONFIGURABLE_AUDIO_PORTS :: "clap.configurable-audio-ports/1"

// Audio port configuration request
Audio_Port_Configuration_Request :: struct {
	// Identifies the port by is_input and port_index
	is_input:      bool,
	port_index:    u32,

	// The requested number of channels.
	channel_count: u32,

	// The port type, see audio-ports.h, Audio_Port_Info.port_type for interpretation.
	port_type:     cstring,

	// cast port_details according to port_type:
	// - AUDIO_PORT_MONO: (discard)
	// - AUDIO_PORT_STEREO: (discard)
	// - AUDIO_PORT_SURROUND: const uint8_t *channel_map
	// - AUDIO_PORT_AMBISONIC: const Ambisonic_Config *info
	port_details:  rawptr,
}

// Plugin configurable audio ports interface
Plugin_Configurable_Audio_Ports :: struct {
	// Returns true if the given configurations can be applied using apply_configuration().
	// [main-thread && !active]
	can_apply_configuration: proc "c" (
		plugin: ^clap.Plugin,
		requests: [^]Audio_Port_Configuration_Request,
		request_count: u32,
	) -> bool,

	// Submit a bunch of configuration requests which will atomically be applied together,
	// or discarded together.
	//
	// Once the configuration is successfully applied, it isn't necessary for the plugin to call
	// Host_Audio_Ports.changed(); and it isn't necessary for the host to scan the audio ports.
	//
	// Returns true if applied.
	// [main-thread && !active]
	apply_configuration:     proc "c" (
		plugin: ^clap.Plugin,
		requests: [^]Audio_Port_Configuration_Request,
		request_count: u32,
	) -> bool,
}
