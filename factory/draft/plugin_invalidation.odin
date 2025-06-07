package clap_factory_draft

import clap "../.."

// Use it to retrieve const Plugin_Invalidation_Factory* from
// Plugin_Entry.get_factory()
PLUGIN_INVALIDATION_FACTORY_ID :: "clap.plugin-invalidation-factory/1"

Plugin_Invalidation_Source :: struct {
	// Directory containing the file(s) to scan, must be absolute
	directory:      cstring,

	// globing pattern, in the form *.dll
	filename_glob:  cstring,

	// should the directory be scanned recursively?
	recursive_scan: bool,
}

// Used to figure out when a plugin needs to be scanned again.
// Imagine a situation with a single entry point: my-plugin.clap which then scans itself
// a set of "sub-plugins". New plugin may be available even if my-plugin.clap file doesn't change.
// This interfaces solves this issue and gives a way to the host to monitor additional files.
Plugin_Invalidation_Factory :: struct {
	// Get the number of invalidation source.
	count:   proc "c" (factory: ^Plugin_Invalidation_Factory) -> u32,

	// Get the invalidation source by its index.
	// [thread-safe]
	get:     proc "c" (
		factory: ^Plugin_Invalidation_Factory,
		index: u32,
	) -> ^Plugin_Invalidation_Source,

	// In case the host detected a invalidation event, it can call refresh() to let the
	// plugin_entry update the set of plugins available.
	// If the function returned false, then the plugin needs to be reloaded.
	refresh: proc "c" (factory: ^Plugin_Invalidation_Factory) -> bool,
}
