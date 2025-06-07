package ext

import clap "../../clap-odin"

// Parameters extension identifier
EXT_PARAMS :: "clap.params"

// Parameter information flags
Param_Info_Flag :: enum u32 {
	STEPPED                 = 1 << 0, // Is this param stepped? (integer values only)
	PERIODIC                = 1 << 1, // Is this param periodic? (wrapped around)
	HIDDEN                  = 1 << 2, // Should not be shown to the user
	READONLY                = 1 << 3, // Readonly parameter
	BYPASS                  = 1 << 4, // Is this parameter used to bypass the plugin?
	AUTOMATABLE             = 1 << 5, // Can this parameter be automated?
	AUTOMATABLE_PER_NOTE_ID = 1 << 6, // Can this parameter be automated per note id?
	AUTOMATABLE_PER_KEY     = 1 << 7, // Can this parameter be automated per key?
	AUTOMATABLE_PER_CHANNEL = 1 << 8, // Can this parameter be automated per channel?
	AUTOMATABLE_PER_PORT    = 1 << 9, // Can this parameter be automated per port?
	MODULATABLE             = 1 << 10, // Can this parameter be modulated?
	MODULATABLE_PER_NOTE_ID = 1 << 11, // Can this parameter be modulated per note id?
	MODULATABLE_PER_KEY     = 1 << 12, // Can this parameter be modulated per key?
	MODULATABLE_PER_CHANNEL = 1 << 13, // Can this parameter be modulated per channel?
	MODULATABLE_PER_PORT    = 1 << 14, // Can this parameter be modulated per port?
	REQUIRES_PROCESS        = 1 << 15, // Changes to this parameter will only take effect during processing
}

Param_Rescan_Flag :: enum u32 {
	VALUES = 1 << 0,
	TEXT   = 1 << 1,
	INFO   = 1 << 2,
	ALL    = 1 << 3,
}

Param_Clear_Flag :: enum u32 {
	ALL         = 1 << 0,
	AUTOMATIONS = 1 << 1,
	MODULATIONS = 1 << 2,
}

// Parameter information structure
Param_Info :: struct {
	id:            clap.Clap_Id, // Stable parameter identifier
	flags:         Param_Info_Flag, // Parameter flags
	cookie:        rawptr, // Plugin private data
	name:          [clap.NAME_SIZE]u8, // Parameter name
	module:        [clap.PATH_SIZE]u8, // Parameter module path (e.g., "Oscillator/Waveform")
	min_value:     f64, // Minimum parameter value
	max_value:     f64, // Maximum parameter value
	default_value: f64, // Default parameter value
}

// Plugin parameters interface
Plugin_Params :: struct {
	// Returns the number of parameters
	// [main-thread]
	count:         proc "c" (plugin: ^clap.Plugin) -> u32,

	// Copies the parameter info to param_info and returns true on success
	// [main-thread]
	get_info:      proc "c" (
		plugin: ^clap.Plugin,
		param_index: u32,
		param_info: ^Param_Info,
	) -> bool,

	// Gets the parameter value
	// [main-thread]
	get_value:     proc "c" (
		plugin: ^clap.Plugin,
		param_id: clap.Clap_Id,
		out_value: ^f64,
	) -> bool,

	// Formats the parameter value to text
	// [main-thread]
	value_to_text: proc "c" (
		plugin: ^clap.Plugin,
		param_id: clap.Clap_Id,
		value: f64,
		out_buffer: [^]u8,
		out_buffer_capacity: u32,
	) -> bool,

	// Converts from text to value
	// [main-thread]
	text_to_value: proc "c" (
		plugin: ^clap.Plugin,
		param_id: clap.Clap_Id,
		param_value_text: cstring,
		out_value: ^f64,
	) -> bool,

	// Flushes parameter changes
	// [main-thread]
	flush:         proc "c" (
		plugin: ^clap.Plugin,
		in_events: ^clap.Input_Events,
		out_events: ^clap.Output_Events,
	),
}

// Host parameters interface
Host_Params :: struct {
	// Rescan the parameter list
	// [main-thread]
	rescan:        proc "c" (host: ^clap.Host, flags: u32),

	// Clear parameter data
	// [main-thread]
	clear:         proc "c" (host: ^clap.Host, param_id: clap.Clap_Id, flags: u32),

	// Request the host to call plugin->flush()
	// [thread-safe]
	request_flush: proc "c" (host: ^clap.Host),
}
