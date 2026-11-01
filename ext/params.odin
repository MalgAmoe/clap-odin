package ext

import clap ".."

// Parameters extension identifier
EXT_PARAMS :: "clap.params"

// Parameter information flags (bitmask, OR-able)
PARAM_IS_STEPPED                 :: 1 << 0
PARAM_IS_PERIODIC                :: 1 << 1
PARAM_IS_HIDDEN                  :: 1 << 2
PARAM_IS_READONLY                :: 1 << 3
// Merges plugin and host bypass controls; implies stepped, with range 0 (off) to 1 (on).
// Only one bypass parameter is allowed per plugin. Its value must not determine
// whether the host calls process(). The plugin handles bypass in process(),
// optionally returning PROCESS_SLEEP to save CPU.
PARAM_IS_BYPASS                  :: 1 << 4
PARAM_IS_AUTOMATABLE             :: 1 << 5
PARAM_IS_AUTOMATABLE_PER_NOTE_ID :: 1 << 6
PARAM_IS_AUTOMATABLE_PER_KEY     :: 1 << 7
PARAM_IS_AUTOMATABLE_PER_CHANNEL :: 1 << 8
PARAM_IS_AUTOMATABLE_PER_PORT    :: 1 << 9
PARAM_IS_MODULATABLE             :: 1 << 10
PARAM_IS_MODULATABLE_PER_NOTE_ID :: 1 << 11
PARAM_IS_MODULATABLE_PER_KEY     :: 1 << 12
PARAM_IS_MODULATABLE_PER_CHANNEL :: 1 << 13
PARAM_IS_MODULATABLE_PER_PORT    :: 1 << 14
PARAM_REQUIRES_PROCESS           :: 1 << 15
PARAM_IS_ENUM                    :: 1 << 16

// Parameter rescan flags (bitmask, OR-able)
PARAM_RESCAN_VALUES :: 1 << 0
PARAM_RESCAN_TEXT   :: 1 << 1
PARAM_RESCAN_INFO   :: 1 << 2
PARAM_RESCAN_ALL    :: 1 << 3

// Parameter clear flags (bitmask, OR-able)
PARAM_CLEAR_ALL         :: 1 << 0
PARAM_CLEAR_AUTOMATIONS :: 1 << 1
PARAM_CLEAR_MODULATIONS :: 1 << 2

// Parameter information structure
Param_Info :: struct {
	id:            clap.Clap_Id, // Stable parameter identifier
	flags:         u32, // Parameter flags, see Param_Info_Flag
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
