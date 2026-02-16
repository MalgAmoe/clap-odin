package ext_draft

import clap "../.."

// This extension enables the plugin to provide the start-page for a webview UI, and exchange
// messages back and forth.
//
// Messages are received in the webview using a standard MessageEvent, with the data in an
// ArrayBuffer. They are posted back to the plugin using window.parent.postMessage(), with the
// data in an ArrayBuffer or TypedArray.

EXT_WEBVIEW :: "clap.webview/3"

// clap.gui API constant. The pointer in clap_window must be NULL, but sizing methods are useful.
// This uses logical size, don't call clap_plugin_gui->set_scale()
WINDOW_API_WEBVIEW :: "webview"

Plugin_Webview :: struct {
	// Writes the URL for the webview's initial navigation to the provided `uri` buffer as a
	// null-terminated UTF-8 string.
	//
	// This must be called at least once before any messages are sent (or accepted) by the host.
	// Absolute URIs (including `data:`, and `file:` URIs on local systems) are always supported.
	// Relative URIs (with absolute paths) refer to resources provided by .get_resource(), which
	// may be provided to the webview with an arbitrary scheme or URI prefix. The host may also
	// translate `file:` URIs to some other scheme or path root, to limit access scope or handle
	// virtual filesystems. Therefore, when using either relative or `file:` URIs, pages must not
	// assume a particular absolute path, only relative paths between resources.
	//
	// Returns either the full length of the URI (including the null terminator), or <= 0 for an
	// error. If the value returned is greater than the capacity, then the result was truncated.
	// If the capacity is 0, `uri` may be a null pointer. In this case, the length of the URI is
	// returned without writing to `uri`, allowing the host to preallocate a buffer for a subsequent
	// call.
	// [main-thread]
	get_uri:      proc "c" (plugin: ^clap.Plugin, uri: [^]u8, uri_capacity: u32) -> i32,

	// Provides the media type and data for resources, starting with the URI from get_uri().
	// The path must be absolute (starting with `/`) with any host-defined path prefix removed.
	// Writes null-terminated media type (MIME type) to the `mime` output buffer if the capacity
	// is large enough, and streams resource data to `data_stream`.
	// Returns true if the media type and entire contents of the resource were provided.
	//
	// [main-thread]
	get_resource: proc "c" (
		plugin: ^clap.Plugin,
		path: cstring,
		mime: [^]u8,
		mime_capacity: u32,
		data_stream: ^clap.Output_Stream,
	) -> bool,

	// Receives a single message from the webview, which must be open and ready to receive replies.
	// Returns true on success.
	// [main-thread]
	receive:      proc "c" (plugin: ^clap.Plugin, buffer: rawptr, size: u32) -> bool,
}

Host_Webview :: struct {
	// Sends a single message to the webview.
	// Returns true on success. It must fail (false) if the webview is not open.
	// [main-thread]
	send: proc "c" (host: ^clap.Host, buffer: rawptr, size: u32) -> bool,
}
