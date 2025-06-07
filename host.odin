package clap

import "core:c"

// Host interface provided by the host to the plugin
Host :: struct {
	clap_version:     Version, // initialized to CLAP_VERSION
	host_data:        rawptr, // reserved pointer for the host

	// name and version are mandatory.
	name:             cstring, // eg: "Bitwig Studio"
	vendor:           cstring, // eg: "Bitwig GmbH"
	url:              cstring, // eg: "https://bitwig.com"
	version:          cstring, // eg: "4.3", see plugin.h for advice on how to format the version

	// Query an extension.
	// The returned pointer is owned by the host.
	// It is forbidden to call it before plugin->init().
	// You can call it within plugin->init() call, and after.
	// [thread-safe]
	get_extension:    proc "c" (host: ^Host, extension_id: cstring) -> rawptr,

	// Request the host to deactivate and then reactivate the plugin.
	// The operation may be delayed by the host.
	// [thread-safe]
	request_restart:  proc "c" (host: ^Host),

	// Request the host to activate and start processing the plugin.
	// This is useful if you have external IO and need to wake up the plugin from "sleep".
	// [thread-safe]
	request_process:  proc "c" (host: ^Host),

	// Request the host to schedule a call to plugin->on_main_thread(plugin) on the main thread.
	// This callback should be called as soon as practicable, usually in the host application's next
	// available main thread time slice. Typically callbacks occur within 33ms / 30hz.
	// Despite this guidance, plugins should not make assumptions about the exactness of timing for
	// a main thread callback, but hosts should endeavour to be prompt. For example, in high load
	// situations the environment may starve the gui/main thread in favor of audio processing,
	// leading to substantially longer latencies for the callback than the indicative times given
	// here.
	// [thread-safe]
	request_callback: proc "c" (host: ^Host),
}
