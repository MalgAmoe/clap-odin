package ext

import clap ".."

// This extension lets the host tell the plugin to display a little color based indication on the
// parameter. This can be used to indicate:
// - a physical controller is mapped to a parameter
// - the parameter is current playing an automation
// - the parameter is overriding the automation
// - etc...
//
// The color semantic depends upon the host here and the goal is to have a consistent experience
// across all plugins.

EXT_PARAM_INDICATION :: "clap.param-indication/4"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_PARAM_INDICATION_COMPAT :: "clap.param-indication.draft/4"

// Param indication automation states
PARAM_INDICATION_AUTOMATION_NONE       :: 0 // No automation for this parameter
PARAM_INDICATION_AUTOMATION_PRESENT    :: 1 // Has automation, but not playing
PARAM_INDICATION_AUTOMATION_PLAYING    :: 2 // Playing automation
PARAM_INDICATION_AUTOMATION_RECORDING  :: 3 // Recording automation
PARAM_INDICATION_AUTOMATION_OVERRIDING :: 4 // User is overriding automation playback

Plugin_Param_Indication :: struct {
	// Sets or clears a mapping indication.
	//
	// has_mapping: does the parameter currently has a mapping?
	// color: if set, the color to use to highlight the control in the plugin GUI
	// label: if set, a small string to display on top of the knob which identifies the hardware
	// controller description: if set, a string which can be used in a tooltip, which describes the
	// current mapping
	//
	// Parameter indications should not be saved in the plugin context, and are off by default.
	// [main-thread]
	set_mapping:    proc "c" (
		plugin: ^clap.Plugin,
		param_id: clap.Clap_Id,
		has_mapping: bool,
		color: ^clap.Color,
		label: cstring,
		description: cstring,
	),

	// Sets or clears an automation indication.
	//
	// automation_state: current automation state for the given parameter
	// color: if set, the color to use to display the automation indication in the plugin GUI
	//
	// Parameter indications should not be saved in the plugin context, and are off by default.
	// [main-thread]
	set_automation: proc "c" (
		plugin: ^clap.Plugin,
		param_id: clap.Clap_Id,
		automation_state: u32,
		color: ^clap.Color,
	),
}
