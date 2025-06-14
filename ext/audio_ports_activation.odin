package ext

import clap ".."

// This extension provides a way for the host to activate and de-activate audio ports.
// Deactivating a port provides the following benefits:
// - the plugin knows ahead of time that a given input is not present and can choose
//   an optimized computation path,
// - the plugin knows that an output is not consumed by the host, and doesn't need to
//   compute it.
//
// Audio ports can only be activated or deactivated when the plugin is deactivated, unless
// can_activate_while_processing() returns true.
//
// Audio buffers must still be provided if the audio port is deactivated.
// In such case, they shall be filled with 0 (or whatever is the neutral value in your context)
// and the constant_mask shall be set.
//
// Audio ports are initially in the active state after creating the plugin instance.
// Audio ports state are not saved in the plugin state, so the host must restore the
// audio ports state after creating the plugin instance.
//
// Audio ports state is invalidated by Plugin_Audio_Ports_Config.select() and
// Host_Audio_Ports.rescan(AUDIO_PORTS_RESCAN_LIST).

EXT_AUDIO_PORTS_ACTIVATION :: "clap.audio-ports-activation/2"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_AUDIO_PORTS_ACTIVATION_COMPAT :: "clap.audio-ports-activation/draft-2"

Plugin_Audio_Ports_Activation :: struct {
	// Returns true if the plugin supports activation/deactivation while processing.
	// [main-thread]
	can_activate_while_processing: proc "c" (plugin: ^clap.Plugin) -> bool,

	// Activate the given port.
	//
	// It is only possible to activate and de-activate on the audio-thread if
	// can_activate_while_processing() returns true.
	//
	// sample_size indicate if the host will provide 32 bit audio buffers or 64 bits one.
	// Possible values are: 32, 64 or 0 if unspecified.
	//
	// returns false if failed, or invalid parameters
	// [active ? audio-thread : main-thread]
	set_active:                    proc "c" (
		plugin: ^clap.Plugin,
		is_input: bool,
		port_index: u32,
		is_active: bool,
		sample_size: u32,
	) -> bool,
}
