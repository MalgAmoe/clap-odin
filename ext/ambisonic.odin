package ext

import clap ".."

// This extension can be used to specify the channel mapping used by the plugin.

EXT_AMBISONIC :: "clap.ambisonic/3"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_AMBISONIC_COMPAT :: "clap.ambisonic.draft/3"

PORT_AMBISONIC :: "ambisonic"

Ambisonic_Ordering :: enum u32 {
	// FuMa channel ordering
	FUMA = 0,

	// ACN channel ordering
	ACN  = 1,
}

Ambisonic_Normalization :: enum u32 {
	MAXN = 0,
	SN3D = 1,
	N3D  = 2,
	SN2D = 3,
	N2D  = 4,
}

Ambisonic_Config :: struct {
	ordering:      u32, // see Ambisonic_Ordering
	normalization: u32, // see Ambisonic_Normalization
}

Plugin_Ambisonic :: struct {
	// Returns true if the given configuration is supported.
	// [main-thread]
	is_config_supported: proc "c" (plugin: ^clap.Plugin, config: ^Ambisonic_Config) -> bool,

	// Returns true on success
	// [main-thread]
	get_config:          proc "c" (
		plugin: ^clap.Plugin,
		is_input: bool,
		port_index: u32,
		config: ^Ambisonic_Config,
	) -> bool,
}

Host_Ambisonic :: struct {
	// Informs the host that the info has changed.
	// The info can only change when the plugin is de-activated.
	// [main-thread]
	changed: proc "c" (host: ^clap.Host),
}
