package clap_factory_draft

import clap "../.."

Plugin_State_Converter_Descriptor :: struct {
	clap_version:  clap.Version,
	src_plugin_id: clap.Universal_Plugin_Id,
	dst_plugin_id: clap.Universal_Plugin_Id,
	id:            cstring, // eg: "com.u-he.diva-converter", mandatory
	name:          cstring, // eg: "Diva Converter", mandatory
	vendor:        cstring, // eg: "u-he"
	version:       cstring, // eg: 1.1.5
	description:   cstring, // eg: "Official state converter for u-he Diva."
}

// This interface provides a mechanism for the host to convert a plugin state and its automation
// points to a new plugin.
//
// This is useful to convert from one plugin ABI to another one.
// This is also useful to offer an upgrade path: from EQ version 1 to EQ version 2.
// This can also be used to convert the state of a plugin that isn't maintained anymore into
// another plugin that would be similar.
Plugin_State_Converter :: struct {
	desc:                     ^Plugin_State_Converter_Descriptor,
	converter_data:           rawptr,

	// Destroy the converter.
	destroy:                  proc "c" (converter: ^Plugin_State_Converter),

	// Converts the input state to a state usable by the destination plugin.
	//
	// error_buffer is a place holder of error_buffer_size bytes for storing a null-terminated
	// error message in case of failure, which can be displayed to the user.
	//
	// Returns true on success.
	// [thread-safe]
	convert_state:            proc "c" (
		converter: ^Plugin_State_Converter,
		src: ^clap.Input_Stream,
		dst: ^clap.Output_Stream,
		error_buffer: [^]u8,
		error_buffer_size: uint,
	) -> bool,

	// Converts a normalized value.
	// Returns true on success.
	// [thread-safe]
	convert_normalized_value: proc "c" (
		converter: ^Plugin_State_Converter,
		src_param_id: clap.Clap_Id,
		src_normalized_value: f64,
		dst_param_id: ^clap.Clap_Id,
		dst_normalized_value: ^f64,
	) -> bool,

	// Converts a plain value.
	// Returns true on success.
	// [thread-safe]
	convert_plain_value:      proc "c" (
		converter: ^Plugin_State_Converter,
		src_param_id: clap.Clap_Id,
		src_plain_value: f64,
		dst_param_id: ^clap.Clap_Id,
		dst_plain_value: ^f64,
	) -> bool,
}

// Factory identifier
PLUGIN_STATE_CONVERTER_FACTORY_ID :: "clap.plugin-state-converter-factory/1"

// List all the plugin state converters available in the current DSO.
Plugin_State_Converter_Factory :: struct {
	// Get the number of converters.
	// [thread-safe]
	count:          proc "c" (factory: ^Plugin_State_Converter_Factory) -> u32,

	// Retrieves a plugin state converter descriptor by its index.
	// Returns null in case of error.
	// The descriptor must not be freed.
	// [thread-safe]
	get_descriptor: proc "c" (
		factory: ^Plugin_State_Converter_Factory,
		index: u32,
	) -> ^Plugin_State_Converter_Descriptor,

	// Create a plugin state converter by its converter_id.
	// The returned pointer must be freed by calling converter->destroy(converter);
	// Returns null in case of error.
	// [thread-safe]
	create:         proc "c" (
		factory: ^Plugin_State_Converter_Factory,
		converter_id: cstring,
	) -> ^Plugin_State_Converter,
}
