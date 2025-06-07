package clap_factory

import clap ".."

// Use it to retrieve const Plugin_Factory* from
// Plugin_Entry.get_factory()
PLUGIN_FACTORY_ID :: "clap.plugin-factory"

// Every method must be thread-safe.
// It is very important to be able to scan the plugin as quickly as possible.
//
// The host may use clap_plugin_invalidation_factory to detect filesystem changes
// which may change the factory's content.
Plugin_Factory :: struct {
	// Get the number of plugins available.
	// [thread-safe]
	get_plugin_count:      proc "c" (factory: ^Plugin_Factory) -> u32,

	// Retrieves a plugin descriptor by its index.
	// Returns null in case of error.
	// The descriptor must not be freed.
	// [thread-safe]
	get_plugin_descriptor: proc "c" (
		factory: ^Plugin_Factory,
		index: u32,
	) -> ^clap.Plugin_Descriptor,

	// Create a clap_plugin by its plugin_id.
	// The returned pointer must be freed by calling plugin->destroy(plugin);
	// The plugin is not allowed to use the host callbacks in the create method.
	// Returns null in case of error.
	// [thread-safe]
	create_plugin:         proc "c" (
		factory: ^Plugin_Factory,
		host: ^clap.Host,
		plugin_id: cstring,
	) -> ^clap.Plugin,
}
