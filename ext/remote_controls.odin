package ext

import clap ".."

// This extension let the plugin provide a structured way of mapping parameters to an hardware
// controller.
//
// This is done by providing a set of remote control pages organized by section.
// A page contains up to 8 controls, which references parameters using param_id.
//
// |`- [section:main]
// |    `- [name:main] performance controls
// |`- [section:osc]
// |   |`- [name:osc1] osc1 page
// |   |`- [name:osc2] osc2 page
// |   |`- [name:osc-sync] osc sync page
// |    `- [name:osc-noise] osc noise page
// |`- [section:filter]
// |   |`- [name:flt1] filter 1 page
// |    `- [name:flt2] filter 2 page
// |`- [section:env]
// |   |`- [name:env1] env1 page
// |    `- [name:env2] env2 page
// |`- [section:lfo]
// |   |`- [name:lfo1] env1 page
// |    `- [name:lfo2] env2 page
//  `- etc...
//
// One possible workflow is to have a set of buttons, which correspond to a section.
// Pressing that button once gets you to the first page of the section.
// Press it again to cycle through the section's pages.

EXT_REMOTE_CONTROLS :: "clap.remote-controls/2"

// The latest draft is 100% compatible
// This compat ID may be removed in 2026.
EXT_REMOTE_CONTROLS_COMPAT :: "clap.remote-controls.draft/2"

REMOTE_CONTROLS_COUNT :: 8

Remote_Controls_Page :: struct {
	section_name:  [clap.NAME_SIZE]u8,
	page_id:       clap.Clap_Id,
	page_name:     [clap.NAME_SIZE]u8,
	param_ids:     [REMOTE_CONTROLS_COUNT]clap.Clap_Id,

	// This is used to separate device pages versus preset pages.
	// If true, then this page is specific to this preset.
	is_for_preset: bool,
}

Plugin_Remote_Controls :: struct {
	// Returns the number of pages.
	// [main-thread]
	count: proc "c" (plugin: ^clap.Plugin) -> u32,

	// Get a page by index.
	// Returns true on success and stores the result into page.
	// [main-thread]
	get:   proc "c" (plugin: ^clap.Plugin, page_index: u32, page: ^Remote_Controls_Page) -> bool,
}

Host_Remote_Controls :: struct {
	// Informs the host that the remote controls have changed.
	// [main-thread]
	changed:      proc "c" (host: ^clap.Host),

	// Suggest a page to the host because it corresponds to what the user is currently editing in the
	// plugin's GUI.
	// [main-thread]
	suggest_page: proc "c" (host: ^clap.Host, page_id: clap.Clap_Id),
}
