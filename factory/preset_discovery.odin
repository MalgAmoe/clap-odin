package clap_factory

import clap ".."

// Use it to retrieve const Preset_Discovery_Factory* from
// Plugin_Entry.get_factory()
PRESET_DISCOVERY_FACTORY_ID :: "clap.preset-discovery-factory/2"

// The latest draft is 100% compatible.
// This compat ID may be removed in 2026.
PRESET_DISCOVERY_FACTORY_ID_COMPAT :: "clap.preset-discovery-factory/draft-2"

Preset_Discovery_Location_Kind :: enum u32 {
	// The preset are located in a file on the OS filesystem.
	// The location is then a path which works with the OS file system functions (open, stat, ...)
	// So both '/' and '\' shall work on Windows as a separator.
	FILE   = 0,

	// The preset is bundled within the plugin DSO itself.
	// The location must then be null, as the preset are within the plugin itself and then the plugin
	// will act as a preset container.
	PLUGIN = 1,
}

Preset_Discovery_Flags :: enum u32 {
	// This is for factory or sound-pack presets.
	IS_FACTORY_CONTENT = 1 << 0,

	// This is for user presets.
	IS_USER_CONTENT    = 1 << 1,

	// This location is meant for demo presets, those are preset which may trigger
	// some limitation in the plugin because they require additional features which the user
	// needs to purchase or the content itself needs to be bought and is only available in
	// demo mode.
	IS_DEMO_CONTENT    = 1 << 2,

	// This preset is a user's favorite
	IS_FAVORITE        = 1 << 3,
}

// Receiver that receives the metadata for a single preset file.
// The host would define the various callbacks in this interface and the preset parser function
// would then call them.
//
// This interface isn't thread-safe.
Preset_Discovery_Metadata_Receiver :: struct {
	receiver_data:    rawptr, // reserved pointer for the metadata receiver

	// If there is an error reading metadata from a file this should be called with an error
	// message.
	// os_error: the operating system error, if applicable. If not applicable set it to a non-error
	// value, eg: 0 on unix and Windows.
	on_error:         proc "c" (
		receiver: ^Preset_Discovery_Metadata_Receiver,
		os_error: i32,
		error_message: cstring,
	),

	// This must be called for every preset in the file and before any preset metadata is
	// sent with the calls below.
	//
	// If the preset file is a preset container then name and load_key are mandatory, otherwise
	// they are optional.
	//
	// The load_key is a machine friendly string used to load the preset inside the container via a
	// the preset-load plug-in extension. The load_key can also just be the subpath if that's what
	// the plugin wants but it could also be some other unique id like a database primary key or a
	// binary offset. It's use is entirely up to the plug-in.
	//
	// If the function returns false, then the provider must stop calling back into the receiver.
	begin_preset:     proc "c" (
		receiver: ^Preset_Discovery_Metadata_Receiver,
		name: cstring,
		load_key: cstring,
	) -> bool,

	// Adds a plug-in id that this preset can be used with.
	add_plugin_id:    proc "c" (
		receiver: ^Preset_Discovery_Metadata_Receiver,
		plugin_id: ^clap.Universal_Plugin_Id,
	),

	// Sets the sound pack to which the preset belongs to.
	set_soundpack_id: proc "c" (
		receiver: ^Preset_Discovery_Metadata_Receiver,
		soundpack_id: cstring,
	),

	// Sets the flags, see Preset_Discovery_Flags.
	// If unset, they are then inherited from the location.
	set_flags:        proc "c" (receiver: ^Preset_Discovery_Metadata_Receiver, flags: u32),

	// Adds a creator name for the preset.
	add_creator:      proc "c" (receiver: ^Preset_Discovery_Metadata_Receiver, creator: cstring),

	// Sets a description of the preset.
	set_description:  proc "c" (
		receiver: ^Preset_Discovery_Metadata_Receiver,
		description: cstring,
	),

	// Sets the creation time and last modification time of the preset.
	// If one of the times isn't known, set it to TIMESTAMP_UNKNOWN.
	// If this function is not called, then the indexer may look at the file's creation and
	// modification time.
	set_timestamps:   proc "c" (
		receiver: ^Preset_Discovery_Metadata_Receiver,
		creation_time: clap.Timestamp,
		modification_time: clap.Timestamp,
	),

	// Adds a feature to the preset.
	//
	// The feature string is arbitrary, it is the indexer's job to understand it and remap it to its
	// internal categorization and tagging system.
	//
	// However, the strings from plugin-features.h should be understood by the indexer and one of the
	// plugin category could be provided to determine if the preset will result into an audio-effect,
	// instrument, ...
	//
	// Examples:
	// kick, drum, tom, snare, clap, cymbal, bass, lead, metalic, hardsync, crossmod, acid,
	// distorted, drone, pad, dirty, etc...
	add_feature:      proc "c" (receiver: ^Preset_Discovery_Metadata_Receiver, feature: cstring),

	// Adds extra information to the metadata.
	add_extra_info:   proc "c" (
		receiver: ^Preset_Discovery_Metadata_Receiver,
		key: cstring,
		value: cstring,
	),
}

Preset_Discovery_Filetype :: struct {
	name:           cstring,
	description:    cstring, // optional

	// `.' isn't included in the string.
	// If empty or NULL then every file should be matched.
	file_extension: cstring,
}

// Defines a place in which to search for presets
Preset_Discovery_Location :: struct {
	flags:    u32, // see Preset_Discovery_Flags
	name:     cstring, // name of this location
	kind:     u32, // See Preset_Discovery_Location_Kind

	// Actual location in which to crawl presets.
	// For FILE kind, the location can be either a path to a directory or a file.
	// For PLUGIN kind, the location must be null.
	location: cstring,
}

// Describes an installed sound pack.
Preset_Discovery_Soundpack :: struct {
	flags:             u32, // see Preset_Discovery_Flags
	id:                cstring, // sound pack identifier
	name:              cstring, // name of this sound pack
	description:       cstring, // optional, reasonably short description of the sound pack
	homepage_url:      cstring, // optional, url to the pack's homepage
	vendor:            cstring, // optional, sound pack's vendor
	image_path:        cstring, // optional, an image on disk
	release_timestamp: clap.Timestamp, // release date, TIMESTAMP_UNKNOWN if unavailable
}

// Describes a preset provider
Preset_Discovery_Provider_Descriptor :: struct {
	clap_version: clap.Version, // initialized to CLAP_VERSION
	id:           cstring, // see plugin.h for advice on how to choose a good identifier
	name:         cstring, // eg: "Diva's preset provider"
	vendor:       cstring, // optional, eg: u-he
}

// This interface isn't thread-safe.
Preset_Discovery_Provider :: struct {
	desc:          ^Preset_Discovery_Provider_Descriptor,
	provider_data: rawptr, // reserved pointer for the provider

	// Initialize the preset provider.
	// It should declare all its locations, filetypes and sound packs.
	// Returns false if initialization failed.
	init:          proc "c" (provider: ^Preset_Discovery_Provider) -> bool,

	// Destroys the preset provider
	destroy:       proc "c" (provider: ^Preset_Discovery_Provider),

	// reads metadata from the given file and passes them to the metadata receiver
	// Returns true on success.
	get_metadata:  proc "c" (
		provider: ^Preset_Discovery_Provider,
		location_kind: u32,
		location: cstring,
		metadata_receiver: ^Preset_Discovery_Metadata_Receiver,
	) -> bool,

	// Query an extension.
	// The returned pointer is owned by the provider.
	// It is forbidden to call it before provider->init().
	// You can call it within provider->init() call, and after.
	get_extension: proc "c" (
		provider: ^Preset_Discovery_Provider,
		extension_id: cstring,
	) -> rawptr,
}

// This interface isn't thread-safe
Preset_Discovery_Indexer :: struct {
	clap_version:      clap.Version, // initialized to CLAP_VERSION
	name:              cstring, // eg: "Bitwig Studio"
	vendor:            cstring, // optional, eg: "Bitwig GmbH"
	url:               cstring, // optional, eg: "https://bitwig.com"
	version:           cstring, // optional, eg: "4.3", see plugin.h for advice on how to format the version
	indexer_data:      rawptr, // reserved pointer for the indexer

	// Declares a preset filetype.
	// Don't callback into the provider during this call.
	// Returns false if the filetype is invalid.
	declare_filetype:  proc "c" (
		indexer: ^Preset_Discovery_Indexer,
		filetype: ^Preset_Discovery_Filetype,
	) -> bool,

	// Declares a preset location.
	// Don't callback into the provider during this call.
	// Returns false if the location is invalid.
	declare_location:  proc "c" (
		indexer: ^Preset_Discovery_Indexer,
		location: ^Preset_Discovery_Location,
	) -> bool,

	// Declares a sound pack.
	// Don't callback into the provider during this call.
	// Returns false if the sound pack is invalid.
	declare_soundpack: proc "c" (
		indexer: ^Preset_Discovery_Indexer,
		soundpack: ^Preset_Discovery_Soundpack,
	) -> bool,

	// Query an extension.
	// The returned pointer is owned by the indexer.
	// It is forbidden to call it before provider->init().
	// You can call it within provider->init() call, and after.
	get_extension:     proc "c" (
		indexer: ^Preset_Discovery_Indexer,
		extension_id: cstring,
	) -> rawptr,
}

// Every methods in this factory must be thread-safe.
// It is encouraged to perform preset indexing in background threads, maybe even in background
// process.
//
// The host may use clap_plugin_invalidation_factory to detect filesystem changes
// which may change the factory's content.
Preset_Discovery_Factory :: struct {
	// Get the number of preset providers available.
	// [thread-safe]
	count:          proc "c" (factory: ^Preset_Discovery_Factory) -> u32,

	// Retrieves a preset provider descriptor by its index.
	// Returns null in case of error.
	// The descriptor must not be freed.
	// [thread-safe]
	get_descriptor: proc "c" (
		factory: ^Preset_Discovery_Factory,
		index: u32,
	) -> ^Preset_Discovery_Provider_Descriptor,

	// Create a preset provider by its id.
	// The returned pointer must be freed by calling preset_provider->destroy(preset_provider);
	// The preset provider is not allowed to use the indexer callbacks in the create method.
	// It is forbidden to call back into the indexer before the indexer calls provider->init().
	// Returns null in case of error.
	// [thread-safe]
	create:         proc "c" (
		factory: ^Preset_Discovery_Factory,
		indexer: ^Preset_Discovery_Indexer,
		provider_id: cstring,
	) -> ^Preset_Discovery_Provider,
}
