package ext_draft

import clap "../.."

// This extension lets the plugin report the current gain adjustment
// (typically, gain reduction) to the host.

EXT_GAIN_ADJUSTMENT_METERING :: "clap.gain-adjustment-metering/0"

Plugin_Gain_Adjustment_Metering :: struct {
	// Returns the current gain adjustment in dB. The value is intended
	// for informational display, for example in a host meter or tooltip.
	// The returned value represents the gain adjustment that the plugin
	// applied to the last sample in the most recently processed block.
	//
	// The returned value is in dB. Zero means the plugin is applying no gain
	// reduction, or is not processing. A negative value means the plugin is
	// applying gain reduction, as with a compressor or limiter. A positive
	// value means the plugin is adding gain, as with an expander. The value
	// represents the dynamic gain reduction or expansion applied by the
	// plugin, before any make-up gain or other adjustment. A single value is
	// returned for all audio channels.
	//
	// [audio-thread]
	get: proc "c" (plugin: ^clap.Plugin) -> f64,
}
