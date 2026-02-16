package ext

import clap ".."

EXT_STATE :: "clap.state"

Plugin_State :: struct {
	save: proc "c" (plugin: ^clap.Plugin, stream: ^clap.Output_Stream) -> bool,
	load: proc "c" (plugin: ^clap.Plugin, stream: ^clap.Input_Stream) -> bool,
}

Host_State :: struct {
	mark_dirty: proc "c" (host: ^clap.Host),
}
