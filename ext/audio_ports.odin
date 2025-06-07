package ext

import clap "../../clap-odin"

//////////////////////
// Audio Ports      //
//////////////////////
// This extension provides a way for the plugin to describe its current audio ports.
//
// If the plugin does not implement this extension, it won't have audio ports.
//
// 32 bits support is required for both host and plugins. 64 bits audio is optional.
//
// The plugin is only allowed to change its ports configuration while it is deactivated.

// Audio ports extension identifier
EXT_AUDIO_PORTS :: "clap.audio-ports"
// Standard port type identifiers
AUDIO_PORT_MONO :: "mono"
AUDIO_PORT_STEREO :: "stereo"

// Audio port flags
Audio_Port_Flag :: enum u32 {
	// This port is the main audio input or output.
	// There can be only one main input and main output.
	// Main port must be at index 0.
	IS_MAIN                     = 1 << 0,

	// This port can be used with 64 bits audio
	SUPPORTS_64BITS             = 1 << 1,

	// 64 bits audio is preferred with this port
	PREFERS_64BITS              = 1 << 2,

	// This port must be used with the same sample size as all the other ports which have this flag.
	// In other words if all ports have this flag then the plugin may either be used entirely with
	// 64 bits audio or 32 bits audio, but it can't be mixed.
	REQUIRES_COMMON_SAMPLE_SIZE = 1 << 3,
}

Audio_Port_Rescan :: enum u32 {
	NAMES         = 1 << 0,
	FLAGS         = 1 << 1,
	CHANNEL_COUNT = 1 << 2,
	PORT_TYPE     = 1 << 3,
	IN_PLACE_PAIR = 1 << 4,
	LIST          = 1 << 5,
}

// Audio port information
Audio_Port_Info :: struct {
	id:            clap.Clap_Id, // Stable port identifier
	name:          [clap.NAME_SIZE]u8, // Port name
	flags:         u32, // Audio port flags
	channel_count: u32, // Number of channels
	port_type:     cstring, // Port type (e.g., "stereo", "mono")
	in_place_pair: u32, // For in-place processing, the output port index
}

Plugin_Audio_Ports :: struct {
	count: proc "c" (plugin: ^clap.Plugin, is_input: bool) -> u32,
	get:   proc "c" (
		plugin: ^clap.Plugin,
		index: u32,
		is_input: bool,
		info: ^Audio_Port_Info,
	) -> bool,
}

Host_Audio_Ports :: struct {
	is_rescan_flag_supported: proc "c" (host: ^clap.Host, flag: u32) -> bool,
	rescan:                   proc "c" (host: ^clap.Host, flags: u32),
}
