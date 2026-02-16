package ext

import clap ".."

EXT_VOICE_INFO :: "clap.voice-info"

// Voice info flags (bitmask, OR-able)
VOICE_INFO_SUPPORTS_OVERLAPPING_NOTES :: 1 << 0

Voice_Info :: struct {
	voice_count:    u32,
	voice_capacity: u32,
	flags:          u64,
}

Plugin_Voice_Info :: struct {
	get: proc "c" (plugin: ^clap.Plugin, info: ^Voice_Info) -> bool,
}

Host_Voice_Info :: struct {
	changed: proc "c" (host: ^clap.Host),
}
