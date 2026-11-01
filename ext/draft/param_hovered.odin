package ext_draft

import clap "../.."

// This extension lets a plugin report to the host the parameter's clap_id of its last hovered UI
// control and whether it is currently hovered (usually hovered by pointer device).

EXT_PARAM_HOVERED :: "clap.param-hovered/1"

Host_Param_Hovered :: struct {
	// Plugin informs the host about a new hover state.
	//
	// Should be called whenever the hovered UI control's parameter ID changes or when it changes
	// from hovered to not being hovered.
	//
	// Only one parameter can be hovered at a time. Use CLAP_INVALID_ID as param_id if no parameter
	// is hovered.
	//
	// [main-thread]
	update: proc "c" (host: ^clap.Host, hovered_param_id: clap.Clap_Id),
}
