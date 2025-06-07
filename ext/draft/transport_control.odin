package ext_draft

import clap "../.."

// This extension lets the plugin submit transport requests to the host.
// The host has no obligation to execute these requests, so the interface may be
// partially working.

EXT_TRANSPORT_CONTROL :: "clap.transport-control/1"

Host_Transport_Control :: struct {
	// Jumps back to the start point and starts the transport
	// [main-thread]
	request_start:         proc "c" (host: ^clap.Host),

	// Stops the transport, and jumps to the start point
	// [main-thread]
	request_stop:          proc "c" (host: ^clap.Host),

	// If not playing, starts the transport from its current position
	// [main-thread]
	request_continue:      proc "c" (host: ^clap.Host),

	// If playing, stops the transport at the current position
	// [main-thread]
	request_pause:         proc "c" (host: ^clap.Host),

	// Equivalent to what "space bar" does with most DAWs
	// [main-thread]
	request_toggle_play:   proc "c" (host: ^clap.Host),

	// Jumps the transport to the given position.
	// Does not start the transport.
	// [main-thread]
	request_jump:          proc "c" (host: ^clap.Host, position: clap.Beat_Time),

	// Sets the loop region
	// [main-thread]
	request_loop_region:   proc "c" (
		host: ^clap.Host,
		start: clap.Beat_Time,
		duration: clap.Beat_Time,
	),

	// Toggles looping
	// [main-thread]
	request_toggle_loop:   proc "c" (host: ^clap.Host),

	// Enables/Disables looping
	// [main-thread]
	request_enable_loop:   proc "c" (host: ^clap.Host, is_enabled: bool),

	// Enables/Disables recording
	// [main-thread]
	request_record:        proc "c" (host: ^clap.Host, is_recording: bool),

	// Toggles recording
	// [main-thread]
	request_toggle_record: proc "c" (host: ^clap.Host),
}
