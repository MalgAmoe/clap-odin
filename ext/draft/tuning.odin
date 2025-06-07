package ext_draft

import clap "../.."

EXT_TUNING :: "clap.tuning/2"

// Use Host_Event_Registry->query(host, EXT_TUNING, &space_id) to know the event space.
//
// This event defines the tuning to be used on the given port/channel.
Event_Tuning :: struct {
	header:     clap.Event_Header,
	port_index: i16, // -1 global
	channel:    i16, // 0..15, -1 global
	tuning_id:  clap.Clap_Id,
}

Tuning_Info :: struct {
	tuning_id:  clap.Clap_Id,
	name:       [clap.NAME_SIZE]u8,
	is_dynamic: bool, // true if the values may vary with time
}

Plugin_Tuning :: struct {
	// Called when a tuning is added or removed from the pool.
	// [main-thread]
	changed: proc "c" (plugin: ^clap.Plugin),
}

// This extension provides a dynamic tuning table to the plugin.
Host_Tuning :: struct {
	// Gets the relative tuning in semitones against equal temperament with A4=440Hz.
	// The plugin may query the tuning at a rate that makes sense for *low* frequency modulations.
	//
	// If the tuning_id is not found or equals to INVALID_ID,
	// then the function shall gracefully return a sensible value.
	//
	// sample_offset is the sample offset from the beginning of the current process block.
	//
	// should_play(...) should be checked before calling this function.
	//
	// [audio-thread & in-process]
	get_relative:     proc "c" (
		host: ^clap.Host,
		tuning_id: clap.Clap_Id,
		channel: i32,
		key: i32,
		sample_offset: u32,
	) -> f64,

	// Returns true if the note should be played.
	// [audio-thread & in-process]
	should_play:      proc "c" (
		host: ^clap.Host,
		tuning_id: clap.Clap_Id,
		channel: i32,
		key: i32,
	) -> bool,

	// Returns the number of tunings in the pool.
	// [main-thread]
	get_tuning_count: proc "c" (host: ^clap.Host) -> u32,

	// Gets info about a tuning
	// Returns true on success and stores the result into info.
	// [main-thread]
	get_info:         proc "c" (host: ^clap.Host, tuning_index: u32, info: ^Tuning_Info) -> bool,
}
