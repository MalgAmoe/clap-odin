package clap

import "core:c"

// This interface is the entry point of the dynamic library.
//
// CLAP plugins standard search path:
//
// Linux
//   - ~/.clap
//   - /usr/lib/clap
//
// Windows
//   - %COMMONPROGRAMFILES%\CLAP
//   - %LOCALAPPDATA%\Programs\Common\CLAP
//
// MacOS
//   - /Library/Audio/Plug-Ins/CLAP
//   - ~/Library/Audio/Plug-Ins/CLAP
//
// In addition to the OS-specific default locations above, a CLAP host must query the environment
// for a CLAP_PATH variable, which is a list of directories formatted in the same manner as the host
// OS binary search path (PATH on Unix, separated by `:` and Path on Windows, separated by ';').
//
// Each directory should be recursively searched for files and/or bundles as appropriate in your OS
// ending with the extension `.clap`.
//
// init and deinit in most cases are called once, in a matched pair, when the dso is loaded / unloaded.
// In some rare situations it may be called multiple times in a process, so the functions must be defensive,
// mutex locking and counting calls if undertaking non trivial non idempotent actions.
Plugin_Entry :: struct {
	clap_version: Version, // initialized to CLAP_VERSION

	// Initializes the DSO.
	//
	// This function must be called first, before any-other CLAP-related function or symbol from this
	// DSO.
	//
	// It also must only be called once, until a later call to deinit() is made, after which init()
	// can be called once more to re-initialize the DSO.
	// This enables hosts to e.g. quickly load and unload a DSO for scanning its plugins, and then
	// load it again later to actually use the plugins if needed.
	//
	// As stated above, even though hosts are forbidden to do so directly, multiple calls before any
	// deinit() call may still happen. Implementations *should* take this into account, and *must*
	// do so as of CLAP 1.2.0.
	//
	// It should be as fast as possible, in order to perform a very quick scan of the plugin
	// descriptors.
	//
	// It is forbidden to display graphical user interfaces in this call.
	// It is forbidden to perform any user interaction in this call.
	//
	// If the initialization depends upon expensive computation, maybe try to do them ahead of time
	// and cache the result.
	//
	// Returns true on success. If init() returns false, then the DSO must be considered
	// uninitialized, and the host must not call deinit() nor any other CLAP-related symbols from the
	// DSO.
	// This function also returns true in the case where the DSO is already initialized, and no
	// actual initialization work is done in this call, as explain above.
	//
	// plugin_path is the path to the DSO (Linux, Windows), or the bundle (macOS).
	//
	// This function may be called on any thread, including a different one from the one a later call
	// to deinit() (or a later init()) can be made.
	// However, it is forbidden to call this function simultaneously from multiple threads.
	// It is also forbidden to call it simultaneously with *any* other CLAP-related symbols from the
	// DSO, including (but not limited to) deinit().
	init:         proc "c" (plugin_path: cstring) -> bool,

	// De-initializes the DSO, freeing any resources allocated or initialized by init().
	//
	// After this function is called, no more calls into the DSO must be made, except calling init()
	// again to re-initialize the DSO.
	// This means that after deinit() is called, the DSO can be considered to be in the same state
	// as if init() was never called at all yet, enabling it to be re-initialized as needed.
	//
	// As stated above, even though hosts are forbidden to do so directly, multiple calls before any
	// new init() call may still happen. Implementations *should* take this into account, and *must*
	// do so as of CLAP 1.2.0.
	//
	// Just like init(), this function may be called on any thread, including a different one from
	// the one init() was called from, or from the one a later init() call can be made.
	// However, it is forbidden to call this function simultaneously from multiple threads.
	// It is also forbidden to call it simultaneously with *any* other CLAP-related symbols from the
	// DSO, including (but not limited to) deinit().
	deinit:       proc "c" (),

	// Get the pointer to a factory. See factory/plugin-factory.h for an example.
	//
	// Returns null if the factory is not provided.
	// The returned pointer must *not* be freed by the caller.
	//
	// Unlike init() and deinit(), this function can be called simultaneously by multiple threads.
	//
	// [thread-safe]
	get_factory:  proc "c" (factory_id: cstring) -> rawptr,
}
