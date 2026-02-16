package ext_draft

import clap "../.."

EXT_TRIGGERS :: "clap.triggers/1"

// Trigger info flags (bitmask, OR-able)
TRIGGER_IS_AUTOMATABLE_PER_NOTE_ID :: 1 << 0
TRIGGER_IS_AUTOMATABLE_PER_KEY     :: 1 << 1
TRIGGER_IS_AUTOMATABLE_PER_CHANNEL :: 1 << 2
TRIGGER_IS_AUTOMATABLE_PER_PORT    :: 1 << 3

// Given that this extension is still draft, it'll use the event-registry and its own event
// namespace until we stabilize it.
EVENT_TRIGGER :: 0

Event_Trigger :: struct {
	header:     clap.Event_Header,

	// target trigger
	trigger_id: clap.Clap_Id, // @ref Trigger_Info.id
	cookie:     rawptr, // @ref Trigger_Info.cookie

	// target a specific note_id, port, key and channel, -1 for global
	note_id:    i32,
	port_index: i16,
	channel:    i16,
	key:        i16,
}

// This describes a trigger
Trigger_Info :: struct {
	// stable trigger identifier, it must never change.
	id:     clap.Clap_Id,
	flags:  u32, // see Trigger_Info_Flags

	// in analogy to Param_Info.cookie
	cookie: rawptr,

	// displayable name
	name:   [clap.NAME_SIZE]u8,

	// the module path containing the trigger, eg:"sequencers/seq1"
	// '/' will be used as a separator to show a tree like structure.
	module: [clap.PATH_SIZE]u8,
}

Plugin_Triggers :: struct {
	// Returns the number of triggers.
	// [main-thread]
	count:    proc "c" (plugin: ^clap.Plugin) -> u32,

	// Copies the trigger's info to trigger_info and returns true on success.
	// [main-thread]
	get_info: proc "c" (plugin: ^clap.Plugin, index: u32, trigger_info: ^Trigger_Info) -> bool,
}

// Trigger rescan flags (bitmask, OR-able)
TRIGGER_RESCAN_INFO :: 1 << 0 // Trigger info changed (name, module). Takes effect immediately.
TRIGGER_RESCAN_ALL  :: 1 << 1 // Full rescan. Only while plugin is deactivated.

// Trigger clear flags (bitmask, OR-able)
TRIGGER_CLEAR_ALL         :: 1 << 0 // Clears all references to a trigger
TRIGGER_CLEAR_AUTOMATIONS :: 1 << 1 // Clears all automations to a trigger

Host_Triggers :: struct {
	// Rescan the full list of triggers according to the flags.
	// [main-thread]
	rescan: proc "c" (host: ^clap.Host, flags: u32),

	// Clears references to a trigger.
	// [main-thread]
	clear:  proc "c" (host: ^clap.Host, trigger_id: clap.Clap_Id, flags: u32),
}
