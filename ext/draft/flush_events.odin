package ext_draft

import clap "../.."

/// @page flush events
///
/// This interface is useful to exchange events with the plugin while not processing.
///
/// This is useful to perform MIDI 2.0 non realtime communication on the main-thread
/// before activating the plugin.

EXT_FLUSH_EVENTS :: "clap.flush-events/1"

Plugin_Flush_Events :: struct {
	// Flushes a set of events.
	// This method must not be called concurrently to clap_plugin->process().
	//
	// Note: if the plugin is processing, then the process() call will already perform events I/O, so
	// a call to flush isn't required, also be aware that the plugin may use the sample offset in
	// process(), while this information would be lost within flush().
	//
	// [active ? audio-thread : main-thread]
	flush: proc "c" (plugin: ^clap.Plugin, in_events: ^clap.Input_Events, out_events: ^clap.Output_Events),
}

Host_Flush_Events :: struct {
	// Request an event flush.
	//
	// The host will then schedule a call to either:
	// - clap_plugin.process()
	// - clap_plugin_flush_events.flush()
	//
	// This function is always safe to use and should not be called from an [audio-thread] as the
	// plugin would already be within process() or flush().
	//
	// [thread-safe,!audio-thread]
	request_flush: proc "c" (host: ^clap.Host),
}
