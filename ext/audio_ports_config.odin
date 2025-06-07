package ext

import clap ".."

// This extension let the plugin provide port configurations presets.
// For example mono, stereo, surround, ambisonic, ...
//
// After the plugin initialization, the host may scan the list of configurations and eventually
// select one that fits the plugin context. The host can only select a configuration if the plugin
// is deactivated.
//
// A configuration is a very simple description of the audio ports:
// - it describes the main input and output ports
// - it has a name that can be displayed to the user
//
// The idea behind the configurations, is to let the user choose one via a menu.
//
// Plugins with very complex configuration possibilities should let the user configure the ports
// from the plugin GUI, and call Host_Audio_Ports.rescan(AUDIO_PORTS_RESCAN_ALL).
//
// To inquire the exact bus layout, the plugin implements the Plugin_Audio_Ports_Config_Info
// extension where all busses can be retrieved in the same way as in the audio-port extension.

EXT_AUDIO_PORTS_CONFIG :: "clap.audio-ports-config"

EXT_AUDIO_PORTS_CONFIG_INFO :: "clap.audio-ports-config-info/1"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_AUDIO_PORTS_CONFIG_INFO_COMPAT :: "clap.audio-ports-config-info/draft-0"

// Minimalistic description of ports configuration
Audio_Ports_Config :: struct {
	id:                        clap.Clap_Id,
	name:                      [clap.NAME_SIZE]u8,
	input_port_count:          u32,
	output_port_count:         u32,

	// main input info
	has_main_input:            bool,
	main_input_channel_count:  u32,
	main_input_port_type:      cstring,

	// main output info
	has_main_output:           bool,
	main_output_channel_count: u32,
	main_output_port_type:     cstring,
}

// The audio ports config scan has to be done while the plugin is deactivated.
Plugin_Audio_Ports_Config :: struct {
	// Gets the number of available configurations
	// [main-thread]
	count:  proc "c" (plugin: ^clap.Plugin) -> u32,

	// Gets information about a configuration
	// Returns true on success and stores the result into config.
	// [main-thread]
	get:    proc "c" (plugin: ^clap.Plugin, index: u32, config: ^Audio_Ports_Config) -> bool,

	// Selects the configuration designated by id
	// Returns true if the configuration could be applied.
	// Once applied the host should scan again the audio ports.
	// [main-thread & plugin-deactivated]
	select: proc "c" (plugin: ^clap.Plugin, config_id: clap.Clap_Id) -> bool,
}

// Extended config info
Plugin_Audio_Ports_Config_Info :: struct {
	// Gets the id of the currently selected config, or CLAP_INVALID_ID if the current port
	// layout isn't part of the config list.
	//
	// [main-thread]
	current_config: proc "c" (plugin: ^clap.Plugin) -> clap.Clap_Id,

	// Get info about an audio port, for a given config_id.
	// This is analogous to Plugin_Audio_Ports.get().
	// Returns true on success and stores the result into info.
	// [main-thread]
	get:            proc "c" (
		plugin: ^clap.Plugin,
		config_id: clap.Clap_Id,
		port_index: u32,
		is_input: bool,
		info: ^Audio_Port_Info,
	) -> bool,
}

Host_Audio_Ports_Config :: struct {
	// Rescan the full list of configs.
	// [main-thread]
	rescan: proc "c" (host: ^clap.Host),
}
