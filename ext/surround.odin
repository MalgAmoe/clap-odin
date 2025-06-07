package ext

import clap ".."

// This extension can be used to specify the channel mapping used by the plugin.
//
// To have consistent surround features across all the plugin instances,
// here is the proposed workflow:
// 1. the plugin queries the host preferred channel mapping and
//    adjusts its configuration to match it.
// 2. the host checks how the plugin is effectively configured and honors it.
//
// If the host decides to change the project's surround setup:
// 1. deactivate the plugin
// 2. host calls Plugin_Surround->changed()
// 3. plugin calls Host_Surround->get_preferred_channel_map()
// 4. plugin eventually calls Host_Surround->changed()
// 5. host calls Plugin_Surround->get_channel_map() if changed
// 6. host activates the plugin and can start processing audio
//
// If the plugin wants to change its surround setup:
// 1. call host->request_restart() if the plugin is active
// 2. once deactivated plugin calls Host_Surround->changed()
// 3. host calls Plugin_Surround->get_channel_map()
// 4. host activates the plugin and can start processing audio

EXT_SURROUND :: "clap.surround/4"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_SURROUND_COMPAT :: "clap.surround.draft/4"

PORT_SURROUND :: "surround"

// Surround channel identifiers
SURROUND_FL :: 0 // Front Left
SURROUND_FR :: 1 // Front Right
SURROUND_FC :: 2 // Front Center
SURROUND_LFE :: 3 // Low Frequency
SURROUND_BL :: 4 // Back (Rear) Left
SURROUND_BR :: 5 // Back (Rear) Right
SURROUND_FLC :: 6 // Front Left of Center
SURROUND_FRC :: 7 // Front Right of Center
SURROUND_BC :: 8 // Back (Rear) Center
SURROUND_SL :: 9 // Side Left
SURROUND_SR :: 10 // Side Right
SURROUND_TC :: 11 // Top (Height) Center
SURROUND_TFL :: 12 // Top (Height) Front Left
SURROUND_TFC :: 13 // Top (Height) Front Center
SURROUND_TFR :: 14 // Top (Height) Front Right
SURROUND_TBL :: 15 // Top (Height) Back (Rear) Left
SURROUND_TBC :: 16 // Top (Height) Back (Rear) Center
SURROUND_TBR :: 17 // Top (Height) Back (Rear) Right
SURROUND_TSL :: 18 // Top (Height) Side Left
SURROUND_TSR :: 19 // Top (Height) Side Right

Plugin_Surround :: struct {
	// Checks if a given channel mask is supported.
	// The channel mask is a bitmask, for example:
	//   (1 << SURROUND_FL) | (1 << SURROUND_FR) | ...
	// [main-thread]
	is_channel_mask_supported: proc "c" (plugin: ^clap.Plugin, channel_mask: u64) -> bool,

	// Stores the surround identifier of each channel into the channel_map array.
	// Returns the number of elements stored in channel_map.
	// channel_map_capacity must be greater or equal to the channel count of the given port.
	// [main-thread]
	get_channel_map:           proc "c" (
		plugin: ^clap.Plugin,
		is_input: bool,
		port_index: u32,
		channel_map: [^]u8,
		channel_map_capacity: u32,
	) -> u32,
}

Host_Surround :: struct {
	// Informs the host that the channel map has changed.
	// The channel map can only change when the plugin is de-activated.
	// [main-thread]
	changed: proc "c" (host: ^clap.Host),
}
