package ext_draft

import clap "../.."

EXT_TRIGGERS :: "clap.triggers/1"

// Trigger flags
Trigger_Info_Flags :: enum u32 {
	// Does this trigger support per note automations?
	IS_AUTOMATABLE_PER_NOTE_ID = 1 << 0,

	// Does this trigger support per key automations?
	IS_AUTOMATABLE_PER_KEY     = 1 << 1,

	// Does this trigger support per channel automations?
	IS_AUTOMATABLE_PER_CHANNEL = 1 << 2,

	// Does this trigger support per port automations?
	IS_AUTOMATABLE_PER_PORT    = 1 << 3,
}

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
	flags:  Trigger_Info_Flags,

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

Trigger_Rescan_Flags :: enum u32 {
	// The trigger info did change, use this flag for:
	// - name change
	// - module change
	// New info takes effect immediately.
	INFO = 1 << 0,

	// Invalidates everything the host knows about triggers.
	// It can only be used while the plugin is deactivated.
	// If the plugin is activated use Host->restart() and delay any change until the host calls
	// Plugin->deactivate().
	//
	// You must use this flag if:
	// - some triggers were added or removed.
	// - some triggers had critical changes:
	//   - is_per_note (flag)
	//   - is_per_key (flag)
	//   - is_per_channel (flag)
	//   - is_per_port (flag)
	//   - cookie
	ALL  = 1 << 1,
}

Trigger_Clear_Flags :: enum u32 {
	// Clears all possible references to a trigger
	ALL         = 1 << 0,

	// Clears all automations to a trigger
	AUTOMATIONS = 1 << 1,
}

Host_Triggers :: struct {
	// Rescan the full list of triggers according to the flags.
	// [main-thread]
	rescan: proc "c" (host: ^clap.Host, flags: Trigger_Rescan_Flags),

	// Clears references to a trigger.
	// [main-thread]
	clear:  proc "c" (host: ^clap.Host, trigger_id: clap.Clap_Id, flags: Trigger_Clear_Flags),
}
