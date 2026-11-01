package ext_draft

import clap "../.."

/// @page background-progress
///
/// @brief Let the plugin report progress to the host for the current background task, and check for
/// cancelation as well.
///
/// This interface reports progress and checks for cancelation for the task currently active on this
/// background thread.
///
/// This interface is used by CLAP_EXT_BACKGROUND_ACTIVATION and CLAP_EXT_BACKGROUND_STATE_CONTEXT.
///
/// Typical execution:
///    plugin->do_something_from_background_thread() {
///       while (!host->is_canceled()) {
///          // do some work
///          host->progress(x, "doing something");
///       }
///    }

EXT_BACKGROUND_PROGRESS :: "clap.background-progress/1"

Host_Background_Progress :: struct {
	// Returns true if the host wants to cancel this task.
	// [background-thread]
	is_canceled: proc "c" (host: ^clap.Host) -> bool,

	// Reports progress to the host.
	// The progress value is from 0 to 1.
	// 0 at the begining and 1 at the end.
	//
	// Be aware that the progress may go backward if a sub-task fails and the plugin decides to retry
	// it.
	//
	// msg: an optional null terminated message (maybe nullptr) explaining what the plugin is currently
	// doing. For example: "Downloading xxx...", "Analyzing...", "Connecting to HW...", and so on.
	//
	// [background-thread]
	progress: proc "c" (host: ^clap.Host, progress: f64, msg: cstring),
}
