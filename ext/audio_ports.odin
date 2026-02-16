package ext

import clap ".."

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

// Audio port flags (bitmask, OR-able)
AUDIO_PORT_IS_MAIN                     :: 1 << 0 // Main audio input or output, must be at index 0
AUDIO_PORT_SUPPORTS_64BITS             :: 1 << 1 // This port can be used with 64 bits audio
AUDIO_PORT_PREFERS_64BITS              :: 1 << 2 // 64 bits audio is preferred with this port
AUDIO_PORT_REQUIRES_COMMON_SAMPLE_SIZE :: 1 << 3 // Must use same sample size as other ports with this flag

// Audio port rescan flags (bitmask, OR-able)
AUDIO_PORT_RESCAN_NAMES         :: 1 << 0
AUDIO_PORT_RESCAN_FLAGS         :: 1 << 1
AUDIO_PORT_RESCAN_CHANNEL_COUNT :: 1 << 2
AUDIO_PORT_RESCAN_PORT_TYPE     :: 1 << 3
AUDIO_PORT_RESCAN_IN_PLACE_PAIR :: 1 << 4
AUDIO_PORT_RESCAN_LIST          :: 1 << 5

// Audio port information
Audio_Port_Info :: struct {
	id:            clap.Clap_Id, // Stable port identifier
	name:          [clap.NAME_SIZE]u8, // Port name
	flags:         u32, // Audio port flags
	channel_count: u32, // Number of channels
	port_type:     cstring, // Port type (e.g., "stereo", "mono")
	in_place_pair: clap.Clap_Id, // For in-place processing, the output port index
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
