package ext

import clap ".."

// This extension lets the host and plugin exchange menu items and let the plugin ask the host to
// show its context menu.

EXT_CONTEXT_MENU :: "clap.context-menu/1"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
EXT_CONTEXT_MENU_COMPAT :: "clap.context-menu.draft/0"

// There can be different target kind for a context menu
Context_Menu_Target_Kind :: enum u32 {
	GLOBAL = 0,
	PARAM  = 1,
}

// Describes the context menu target
Context_Menu_Target :: struct {
	kind: u32,
	id:   clap.Clap_Id,
}

Context_Menu_Item_Kind :: enum u32 {
	// Adds a clickable menu entry.
	// data: const Context_Menu_Entry*
	ENTRY         = 0,

	// Adds a clickable menu entry which will feature both a checkmark and a label.
	// data: const Context_Menu_Check_Entry*
	CHECK_ENTRY   = 1,

	// Adds a separator line.
	// data: NULL
	SEPARATOR     = 2,

	// Starts a sub menu with the given label.
	// data: const Context_Menu_Submenu*
	BEGIN_SUBMENU = 3,

	// Ends the current sub menu.
	// data: NULL
	END_SUBMENU   = 4,

	// Adds a title entry
	// data: const Context_Menu_Item_Title*
	TITLE         = 5,
}

Context_Menu_Entry :: struct {
	// text to be displayed
	label:      cstring,

	// if false, then the menu entry is greyed out and not clickable
	is_enabled: bool,
	action_id:  clap.Clap_Id,
}

Context_Menu_Check_Entry :: struct {
	// text to be displayed
	label:      cstring,

	// if false, then the menu entry is greyed out and not clickable
	is_enabled: bool,

	// if true, then the menu entry will be displayed as checked
	is_checked: bool,
	action_id:  clap.Clap_Id,
}

Context_Menu_Item_Title :: struct {
	// text to be displayed
	title:      cstring,

	// if false, then the menu entry is greyed out
	is_enabled: bool,
}

Context_Menu_Submenu :: struct {
	// text to be displayed
	label:      cstring,

	// if false, then the menu entry is greyed out and won't show submenu
	is_enabled: bool,
}

// Context menu builder.
// This object isn't thread-safe and must be used on the same thread as it was provided.
Context_Menu_Builder :: struct {
	ctx:      rawptr,

	// Adds an entry to the menu.
	// item_data type is determined by item_kind.
	// Returns true on success.
	add_item: proc "c" (
		builder: ^Context_Menu_Builder,
		item_kind: Context_Menu_Item_Kind,
		item_data: rawptr,
	) -> bool,

	// Returns true if the menu builder supports the given item kind
	supports: proc "c" (builder: ^Context_Menu_Builder, item_kind: Context_Menu_Item_Kind) -> bool,
}

Plugin_Context_Menu :: struct {
	// Insert plugin's menu items into the menu builder.
	// If target is null, assume global context.
	// Returns true on success.
	// [main-thread]
	populate: proc "c" (
		plugin: ^clap.Plugin,
		target: ^Context_Menu_Target,
		builder: ^Context_Menu_Builder,
	) -> bool,

	// Performs the given action, which was previously provided to the host via populate().
	// If target is null, assume global context.
	// Returns true on success.
	// [main-thread]
	perform:  proc "c" (
		plugin: ^clap.Plugin,
		target: ^Context_Menu_Target,
		action_id: clap.Clap_Id,
	) -> bool,
}

Host_Context_Menu :: struct {
	// Insert host's menu items into the menu builder.
	// If target is null, assume global context.
	// Returns true on success.
	// [main-thread]
	populate:  proc "c" (
		host: ^clap.Host,
		target: ^Context_Menu_Target,
		builder: ^Context_Menu_Builder,
	) -> bool,

	// Performs the given action, which was previously provided to the plugin via populate().
	// If target is null, assume global context.
	// Returns true on success.
	// [main-thread]
	perform:   proc "c" (
		host: ^clap.Host,
		target: ^Context_Menu_Target,
		action_id: clap.Clap_Id,
	) -> bool,

	// Returns true if the host can display a popup menu for the plugin.
	// This may depend upon the current windowing system used to display the plugin, so the
	// return value is invalidated after creating the plugin window.
	// [main-thread]
	can_popup: proc "c" (host: ^clap.Host) -> bool,

	// Shows the host popup menu for a given parameter.
	// If the plugin is using embedded GUI, then x and y are relative to the plugin's window,
	// otherwise they're absolute coordinate, and screen index might be set accordingly.
	// If target is null, assume global context.
	// Returns true on success.
	// [main-thread]
	popup:     proc "c" (
		host: ^clap.Host,
		target: ^Context_Menu_Target,
		screen_index: i32,
		x: i32,
		y: i32,
	) -> bool,
}
