package ext

import clap "../../clap-odin"

//////////////////////
// State Context   //
//////////////////////
// This extension can be used to specify the context in which the plugin's state
// is being saved or loaded.
//
// This is useful to handle the case where the plugin's state depends on the context.
// For example, a plugin may store different data when it is saved as a project state
// vs when it is saved as a preset.

// State context extension identifier
EXT_STATE_CONTEXT :: "clap.state-context/2"

// State context types
State_Context_Type :: enum u32 {
	FOR_PRESET    = 1, // suitable for storing and loading a state as a preset
	FOR_DUPLICATE = 2, // suitable for duplicating a plugin instance
	FOR_PROJECT   = 3, // suitable for storing and loading a state within a project/song
}

// Plugin state context interface
Plugin_State_Context :: struct {
	// Saves the plugin state into stream, according to context_type.
	// Returns true if the state was correctly saved.
	//
	// Note that the result may be loaded by both Plugin_State.load() and
	// Plugin_State_Context.load().
	// [main-thread]
	save: proc "c" (plugin: ^clap.Plugin, stream: ^clap.OStream, context_type: u32) -> bool,

	// Loads the plugin state from stream, according to context_type.
	// Returns true if the state was correctly restored.
	//
	// Note that the state may have been saved by Plugin_State.save() or
	// Plugin_State_Context.save() with a different context_type.
	// [main-thread]
	load: proc "c" (plugin: ^clap.Plugin, stream: ^clap.IStream, context_type: u32) -> bool,
}
