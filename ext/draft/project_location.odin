package ext_draft

import clap "../.."

// This extension allows a host to tell the plugin more about its position
// within a project or session.

EXT_PROJECT_LOCATION :: "clap.project-location/2"

Project_Location_Kind :: enum u32 {
	// Represents a document/project/session.
	PROJECT             = 1,

	// Represents a group of tracks.
	// It can contain track groups, tracks, and devices (post processing).
	// The first device within a track group has the index of
	// the last track or track group within this group + 1.
	TRACK_GROUP         = 2,

	// Represents a single track.
	// It contains devices (serial).
	TRACK               = 3,

	// Represents a single device.
	// It can contain other nested device chains.
	DEVICE              = 4,

	// Represents a nested device chain (serial).
	// Its parent must be a device.
	// It contains other devices.
	NESTED_DEVICE_CHAIN = 5,
}

Project_Location_Track_Kind :: enum u32 {
	// This track is an instrument track.
	INSTRUMENT_TRACK = 1,

	// This track is an audio track.
	AUDIO_TRACK      = 2,

	// This track is both an instrument and audio track.
	HYBRID_TRACK     = 3,

	// This track is a return track.
	RETURN_TRACK     = 4,

	// This track is a master track.
	// Each group have a master track for processing the sum of all its children tracks.
	MASTER_TRACK     = 5,
}

Project_Location_Flags :: enum u64 {
	HAS_INDEX = 1 << 0,
	HAS_COLOR = 1 << 1,
}

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
