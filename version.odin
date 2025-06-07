package clap

// CLAP version constants - updated to match the latest C API
CLAP_VERSION_MAJOR :: 1
CLAP_VERSION_MINOR :: 2
CLAP_VERSION_REVISION :: 6

CLAP_VERSION :: Version {
	major    = CLAP_VERSION_MAJOR,
	minor    = CLAP_VERSION_MINOR,
	revision = CLAP_VERSION_REVISION,
}

// Check if a CLAP version is compatible with this implementation.
// Versions 0.x.y were used during development stage and aren't compatible.
clap_version_is_compatible :: proc "c" (version: Version) -> bool {
	return version.major >= 1
}

// CLAP version structure
// This is the major ABI and API design
// Version 0.X.Y correspond to the development stage, API and ABI are not stable
// Version 1.X.Y correspond to the release stage, API and ABI are stable
Version :: struct {
	major:    u32, // Major version number
	minor:    u32, // Minor version number  
	revision: u32, // Revision number
}
