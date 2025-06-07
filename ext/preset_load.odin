package ext

import clap ".."

EXT_PRESET_LOAD :: "clap.preset-load/2"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_PRESET_LOAD_COMPAT :: "clap.preset-load.draft/2"

Plugin_Preset_Load :: struct {
	// Loads a preset in the plugin native preset file format from a location.
	// The preset discovery provider defines the location and load_key to be passed to this function.
	// Returns true on success.
	// [main-thread]
	from_location: proc "c" (
		plugin: ^clap.Plugin,
		location_kind: u32,
		location: cstring,
		load_key: cstring,
	) -> bool,
}

Host_Preset_Load :: struct {
	// Called if Plugin_Preset_Load.from_location() failed.
	// os_error: the operating system error, if applicable. If not applicable set it to a non-error
	// value, eg: 0 on unix and Windows.
	//
	// [main-thread]
	on_error: proc "c" (
		host: ^clap.Host,
		location_kind: u32,
		location: cstring,
		load_key: cstring,
		os_error: i32,
		msg: cstring,
	),

	// Informs the host that the following preset has been loaded.
	// This contributes to keep in sync the host preset browser and plugin preset browser.
	// If the preset was loaded from a container file, then the load_key must be set, otherwise it
	// must be null.
	//
	// [main-thread]
	loaded:   proc "c" (
		host: ^clap.Host,
		location_kind: u32,
		location: cstring,
		load_key: cstring,
	),
}
