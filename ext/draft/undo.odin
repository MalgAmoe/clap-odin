package ext_draft

import clap "../.."

EXT_UNDO :: "clap.undo/4"
EXT_UNDO_CONTEXT :: "clap.undo_context/4"
EXT_UNDO_DELTA :: "clap.undo_delta/4"

// This extension enables the plugin to merge its undo history with the host.
// This leads to a single undo history shared by the host and many plugins.

Undo_Delta_Properties :: struct {
	// If true, then the plugin will provide deltas in host->change_made().
	// If false, then all Undo_Delta_Properties's attributes become irrelevant.
	has_delta:             bool,

	// If true, then the deltas can be stored on disk and re-used in the future as long as the plugin
	// is compatible with the given format_version.
	//
	// If false, then format_version must be set to INVALID_ID.
	are_deltas_persistent: bool,

	// This represents the delta format version that the plugin is currently using.
	// Use INVALID_ID for invalid value.
	format_version:        clap.Clap_Id,
}

// Use EXT_UNDO_DELTA.
// This is an optional interface, using deltas is an optimization versus making a state snapshot.
Plugin_Undo_Delta :: struct {
	// Asks the plugin the delta properties.
	// [main-thread]
	get_delta_properties:         proc "c" (
		plugin: ^clap.Plugin,
		properties: ^Undo_Delta_Properties,
	),

	// Asks the plugin if it can apply a delta using the given format version.
	// Returns true if it is possible.
	// [main-thread]
	can_use_delta_format_version: proc "c" (
		plugin: ^clap.Plugin,
		format_version: clap.Clap_Id,
	) -> bool,

	// Undo using the delta.
	// Returns true on success.
	//
	// [main-thread]
	undo:                         proc "c" (
		plugin: ^clap.Plugin,
		format_version: clap.Clap_Id,
		delta: rawptr,
		delta_size: uint,
	) -> bool,

	// Redo using the delta.
	// Returns true on success.
	//
	// [main-thread]
	redo:                         proc "c" (
		plugin: ^clap.Plugin,
		format_version: clap.Clap_Id,
		delta: rawptr,
		delta_size: uint,
	) -> bool,
}

// Use EXT_UNDO_CONTEXT.
// This is an optional interface, that the plugin can implement in order to know about
// the current undo context.
Plugin_Undo_Context :: struct {
	// Indicate if it is currently possible to perform an undo or redo operation.
	// [main-thread & plugin-subscribed-to-undo-context]
	set_can_undo:  proc "c" (plugin: ^clap.Plugin, can_undo: bool),
	set_can_redo:  proc "c" (plugin: ^clap.Plugin, can_redo: bool),

	// Sets the name of the next undo or redo step.
	// name: null terminated string.
	// [main-thread & plugin-subscribed-to-undo-context]
	set_undo_name: proc "c" (plugin: ^clap.Plugin, name: cstring),
	set_redo_name: proc "c" (plugin: ^clap.Plugin, name: cstring),
}

// Use EXT_UNDO.
Host_Undo :: struct {
	// Begins a long running change.
	// The plugin must not call this twice: there must be either a call to cancel_change() or
	// change_made() before calling begin_change() again.
	// [main-thread]
	begin_change:              proc "c" (host: ^clap.Host),

	// Cancels a long running change.
	// cancel_change() must not be called without a preceding begin_change().
	// [main-thread]
	cancel_change:             proc "c" (host: ^clap.Host),

	// Completes an undoable change.
	// At the moment of this function call, plugin_state->save() would include the current change.
	//
	// name: mandatory null terminated string describing the change, this is displayed to the user
	//
	// delta: optional, it is a binary blobs used to perform the undo and redo. When not available
	// the host will save the plugin state and use state->load() to perform undo and redo.
	// The plugin must be able to perform a redo operation using the delta, though the undo operation
	// is only possible if delta_can_undo is true.
	//
	// [main-thread]
	change_made:               proc "c" (
		host: ^clap.Host,
		name: cstring,
		delta: rawptr,
		delta_size: uint,
		delta_can_undo: bool,
	),

	// Asks the host to perform the next undo or redo step.
	//
	// [main-thread]
	request_undo:              proc "c" (host: ^clap.Host),
	request_redo:              proc "c" (host: ^clap.Host),

	// Subscribes to or unsubscribes from undo context info.
	//
	// is_subscribed: set to true to receive context info
	//
	// It is mandatory for the plugin to implement EXT_UNDO_CONTEXT when using this method.
	//
	// [main-thread]
	set_wants_context_updates: proc "c" (host: ^clap.Host, is_subscribed: bool),
}
