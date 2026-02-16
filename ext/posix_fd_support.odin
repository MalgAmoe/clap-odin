package ext

import clap ".."

import "core:c"

EXT_POSIX_FD_SUPPORT :: "clap.posix-fd-support"

// Posix FD event flags (bitmask, OR-able)
POSIX_FD_READ  :: 1 << 0
POSIX_FD_WRITE :: 1 << 1
POSIX_FD_ERROR :: 1 << 2

Plugin_Posix_FD_Support :: struct {
	on_fd: proc "c" (plugin: ^clap.Plugin, fd: c.int, flags: u32),
}

Host_Posix_FD_Support :: struct {
	register_fd:   proc "c" (host: ^clap.Host, fd: c.int, flags: u32) -> bool,
	modify_fd:     proc "c" (host: ^clap.Host, fd: c.int, flags: u32) -> bool,
	unregister_fd: proc "c" (host: ^clap.Host, fd: c.int) -> bool,
}
