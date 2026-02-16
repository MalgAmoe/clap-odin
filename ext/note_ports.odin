package ext

import clap ".."

// This extension provides a way for the plugin to describe its current note ports.
// If the plugin does not implement this extension, it won't have note input or output.
// The plugin is only allowed to change its note ports configuration while it is deactivated.

EXT_NOTE_PORTS :: "clap.note-ports"

// Note dialect flags (bitmask, OR-able)
NOTE_DIALECT_CLAP     :: 1 << 0 // Uses Event_Note and Event_Note_Expression
NOTE_DIALECT_MIDI     :: 1 << 1 // Uses Event_Midi, no polyphonic expression
NOTE_DIALECT_MIDI_MPE :: 1 << 2 // Uses Event_Midi, with polyphonic expression (MPE)
NOTE_DIALECT_MIDI2    :: 1 << 3 // Uses Event_Midi2

Note_Port_Info :: struct {
	// id identifies a port and must be stable.
	// id may overlap between input and output ports.
	id:                 clap.Clap_Id,
	supported_dialects: u32, // bitfield, see Note_Dialect
	preferred_dialect:  u32, // one value of Note_Dialect
	name:               [clap.NAME_SIZE]u8, // displayable name, i18n?
}

// The note ports scan has to be done while the plugin is deactivated.
Plugin_Note_Ports :: struct {
	// Number of ports, for either input or output.
	// [main-thread]
	count: proc "c" (plugin: ^clap.Plugin, is_input: bool) -> u32,

	// Get info about a note port.
	// Returns true on success and stores the result into info.
	// [main-thread]
	get:   proc "c" (
		plugin: ^clap.Plugin,
		index: u32,
		is_input: bool,
		info: ^Note_Port_Info,
	) -> bool,
}

// Note ports rescan flags (bitmask, OR-able)
NOTE_PORTS_RESCAN_ALL   :: 1 << 0 // Full port scan required (plugin must be deactivated)
NOTE_PORTS_RESCAN_NAMES :: 1 << 1 // Port names changed, host can scan immediately

Host_Note_Ports :: struct {
	// Query which dialects the host supports
	// [main-thread]
	supported_dialects: proc "c" (host: ^clap.Host) -> u32,

	// Rescan the full list of note ports according to the flags.
	// [main-thread]
	rescan:             proc "c" (host: ^clap.Host, flags: u32),
}
