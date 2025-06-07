package ext

import clap "../../clap-odin"


// Thread Pool
EXT_THREAD_POOL :: "clap.thread-pool"

Plugin_Thread_Pool :: struct {
	exec: proc "c" (plugin: ^clap.Plugin, task_index: u32),
}

Host_Thread_Pool :: struct {
	request_exec: proc "c" (host: ^clap.Host, num_tasks: u32) -> bool,
}
