package ext_draft

import clap "../.."

/// @page background state context
/// @brief Save and Load state from a background thread.
///
/// Some plugin needs to perform complex computation or even I/O during state loading or saving and
/// this blocks the main thread.
///
/// This extension is here to offer an alternative way to load or save the plugin from a
/// background thread, to keep the main-thread running.
///
/// Background save and load must not be concurrent to main-thread save and load.
///
/// Implementing this extension implies that background state saving and loading
/// are beneficial and preferred for this plugin.

EXT_BACKGROUND_STATE_CONTEXT :: "clap.background-state-context/1"

Plugin_Background_State_Context :: struct {
	// Same as clap_plugin_state_context.save() but it is called from a background thread.
	// See clap_host_background_progress for progress feedback and cancelation.
	// [background-thread]
	save_from_background_thread: proc "c" (plugin: ^clap.Plugin, stream: ^clap.Output_Stream, context_type: u32) -> bool,

	// Same as clap_plugin_state_context.load() but it is called from a background thread.
	// See clap_host_background_progress for progress feedback and cancelation.
	// [background-thread]
	load_from_background_thread: proc "c" (plugin: ^clap.Plugin, stream: ^clap.Input_Stream, context_type: u32) -> bool,
}
