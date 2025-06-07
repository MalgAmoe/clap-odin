package ext

import clap "../../clap-odin"

// Note Name
EXT_NOTE_NAME :: "clap.note-name"

Note_Name :: struct {
	name:    [clap.NAME_SIZE]u8,
	port:    i16,
	key:     i16,
	channel: i16,
}

Plugin_Note_Name :: struct {
	count: proc "c" (plugin: ^clap.Plugin) -> u32,
	get:   proc "c" (plugin: ^clap.Plugin, index: u32, note_name: ^Note_Name) -> bool,
}

Host_Note_Name :: struct {
	changed: proc "c" (host: ^clap.Host),
}
