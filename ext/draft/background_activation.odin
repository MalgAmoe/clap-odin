package ext_draft

import clap "../.."

/// @page background activation
/// @brief Activate and Deactivate from a background thread.
///
/// Some plugin needs to perform complex computation or even I/O during activation
/// and this blocks the main thread.
///
/// This extension is here to offer an alternative way to activate the plugin from a background
/// thread, to keep the main-thread running.
///
/// Background activation must not be concurrent to a plugin activation/deactivation on the
/// main-thread.
///
/// Implementing this extension implies that background activation and deactivation
/// are beneficial and preferred for this plugin.

EXT_BACKGROUND_ACTIVATION :: "clap.background-activation/1"

Plugin_Background_Activation :: struct {
	// Same as clap_plugin.activate() but it is called from a background thread.
	// See clap_host_background_progress for progress feedback and cancelation.
	//
	// [background-thread]
	activate_from_background_thread: proc "c" (plugin: ^clap.Plugin, sample_rate: f64, min_frames_count: u32, max_frames_count: u32) -> bool,

	// Same as clap_plugin.deactivate() but it is called from a background thread.
	// See clap_host_background_progress for progress feedback and cancelation.
	//
	// [background-thread]
	deactivate_from_background_thread: proc "c" (plugin: ^clap.Plugin),
}
