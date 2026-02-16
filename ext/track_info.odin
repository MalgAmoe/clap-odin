package ext

import clap ".."

// This extension let the plugin query info about the track it's in.
// It is useful when the plugin is created, to initialize some parameters (mix, dry, wet)
// and pick a suitable configuration regarding audio port type and channel count.

EXT_TRACK_INFO :: "clap.track-info/1"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_TRACK_INFO_COMPAT :: "clap.track-info.draft/1"

// Track info flags (bitmask, OR-able)
TRACK_INFO_HAS_TRACK_NAME      :: 1 << 0
TRACK_INFO_HAS_TRACK_COLOR     :: 1 << 1
TRACK_INFO_HAS_AUDIO_CHANNEL   :: 1 << 2
TRACK_INFO_IS_FOR_RETURN_TRACK :: 1 << 3 // On a return track, initialize with wet 100%
TRACK_INFO_IS_FOR_BUS          :: 1 << 4 // On a bus track
TRACK_INFO_IS_FOR_MASTER       :: 1 << 5 // On the master

Track_Info :: struct {
	flags:               u64, // see Track_Info_Flags above

	// track name, available if flags contain HAS_TRACK_NAME
	name:                [clap.NAME_SIZE]u8,

	// track color, available if flags contain HAS_TRACK_COLOR
	color:               clap.Color,

	// available if flags contain HAS_AUDIO_CHANNEL
	// see audio-ports.h, struct Audio_Port_Info to learn how to use channel count and port type
	audio_channel_count: i32,
	audio_port_type:     cstring,
}

Plugin_Track_Info :: struct {
	// Called when the info changes.
	// [main-thread]
	changed: proc "c" (plugin: ^clap.Plugin),
}

Host_Track_Info :: struct {
	// Get info about the track the plugin belongs to.
	// Returns true on success and stores the result into info.
	// [main-thread]
	get: proc "c" (host: ^clap.Host, info: ^Track_Info) -> bool,
}
