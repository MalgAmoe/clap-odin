package ext

import clap ".."

// This extension can be used to specify the channel mapping used by the plugin.

EXT_AMBISONIC :: "clap.ambisonic/3"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_AMBISONIC_COMPAT :: "clap.ambisonic.draft/3"

PORT_AMBISONIC :: "ambisonic"

// Ambisonic ordering values
AMBISONIC_ORDERING_FUMA :: 0 // FuMa channel ordering
AMBISONIC_ORDERING_ACN  :: 1 // ACN channel ordering

// Ambisonic normalization values
AMBISONIC_NORMALIZATION_MAXN :: 0
AMBISONIC_NORMALIZATION_SN3D :: 1
AMBISONIC_NORMALIZATION_N3D  :: 2
AMBISONIC_NORMALIZATION_SN2D :: 3
AMBISONIC_NORMALIZATION_N2D  :: 4

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
