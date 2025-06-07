package ext_draft

import clap "../.."

EXT_RESOURCE_DIRECTORY :: "clap.resource-directory/1"

// This extension provides a way for the plugin to store its resources as file in a directory
// provided by the host and recover them later on.
//
// The plugin **must** store relative path in its state toward resource directories.
//
// Resource sharing:
// - shared directory is shared among all plugin instances, hence mostly appropriate for read-only
// content
//   -> suitable for read-only content
// - exclusive directory is exclusive to the plugin instance
//   -> if the plugin, then its exclusive directory must be duplicated too
//   -> suitable for read-write content

Plugin_Resource_Directory :: struct {
	// Sets the directory in which the plugin can save its resources.
	// The directory remains valid until it is overridden or the plugin is destroyed.
	// If path is null or blank, it clears the directory location.
	// path must be absolute.
	// [main-thread]
	set_directory:   proc "c" (plugin: ^clap.Plugin, path: cstring, is_shared: bool),

	// Asks the plugin to put its resources into the resource directory.
	// It is not necessary to collect files which belongs to the plugin's
	// factory content unless the param all is true.
	// [main-thread]
	collect:         proc "c" (plugin: ^clap.Plugin, all: bool),

	// Returns the number of files used by the plugin in the shared resource folder.
	// [main-thread]
	get_files_count: proc "c" (plugin: ^clap.Plugin) -> u32,

	// Retrieves relative file path to the resource directory.
	// @param path writable memory to store the path
	// @param path_size number of available bytes in path
	// Returns the number of bytes in the path, or -1 on error
	// [main-thread]
	get_file_path:   proc "c" (
		plugin: ^clap.Plugin,
		index: u32,
		path: [^]u8,
		path_size: u32,
	) -> i32,
}

Host_Resource_Directory :: struct {
	// Request the host to setup a resource directory with the specified sharing.
	// Returns true if the host will perform the request.
	// [main-thread]
	request_directory: proc "c" (host: ^clap.Host, is_shared: bool) -> bool,

	// Tell the host that the resource directory of the specified sharing is no longer required.
	// If is_shared = false, then the host may delete the directory content.
	// [main-thread]
	release_directory: proc "c" (host: ^clap.Host, is_shared: bool),
}
