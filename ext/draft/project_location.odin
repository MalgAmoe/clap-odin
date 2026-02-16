package ext_draft

import clap "../.."

// This extension allows a host to tell the plugin more about its position
// within a project or session.

EXT_PROJECT_LOCATION :: "clap.project-location/2"

// Project location kinds
PROJECT_LOCATION_PROJECT             :: 1 // Document/project/session
PROJECT_LOCATION_TRACK_GROUP         :: 2 // Group of tracks
PROJECT_LOCATION_TRACK               :: 3 // Single track, contains devices (serial)
PROJECT_LOCATION_DEVICE              :: 4 // Single device, can contain nested device chains
PROJECT_LOCATION_NESTED_DEVICE_CHAIN :: 5 // Nested device chain (serial), parent must be a device

// Project location track kinds
PROJECT_LOCATION_INSTRUMENT_TRACK :: 1
PROJECT_LOCATION_AUDIO_TRACK      :: 2
PROJECT_LOCATION_HYBRID_TRACK     :: 3 // Both instrument and audio
PROJECT_LOCATION_RETURN_TRACK     :: 4
PROJECT_LOCATION_MASTER_TRACK     :: 5 // Processes the sum of all children tracks

// Project location flags (bitmask, OR-able)
PROJECT_LOCATION_HAS_INDEX :: 1 << 0
PROJECT_LOCATION_HAS_COLOR :: 1 << 1

Project_Location_Element :: struct {
	// A bit-mask, see Project_Location_Flags.
	flags:      u64,

	// Kind of the element, must be one of the Project_Location_Kind values.
	kind:       u32,

	// Only relevant if kind is TRACK.
	// see Project_Location_Track_Kind.
	track_kind: u32,

	// Index within the parent element.
	// Only usable if HAS_INDEX is set in flags.
	index:      u32,

	// Internal ID of the element.
	// This is not intended for display to the user,
	// but rather to give the host a potential quick way for lookups.
	id:         [clap.PATH_SIZE]u8,

	// User friendly name of the element.
	name:       [clap.NAME_SIZE]u8,

	// Color for this element.
	// Only usable if HAS_COLOR is set in flags.
	color:      clap.Color,
}

Plugin_Project_Location :: struct {
	// Called by the host when the location of the plugin instance changes.
	//
	// The last item in this array always refers to the device itself, and as
	// such is expected to be of kind DEVICE.
	// The first item in this array always refers to the project this device is in and must be of
	// kind PROJECT. The path is expected to be something like: PROJECT >
	// TRACK_GROUP+ > TRACK > (DEVICE > NESTED_DEVICE_CHAIN)* > DEVICE
	//
	// [main-thread]
	set: proc "c" (plugin: ^clap.Plugin, path: [^]Project_Location_Element, num_elements: u32),
}
