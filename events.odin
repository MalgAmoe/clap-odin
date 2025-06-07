package clap

// The clap core event space
CORE_EVENT_SPACE_ID :: 0

// Event flags for additional event metadata
Event_Flags :: enum u32 {
	// Indicate a live user event, for example a user turning a physical knob
	// or playing a physical key.
	IS_LIVE     = 1 << 0,
	// Indicate that the event should not be recorded.
	// For example this is useful when a parameter changes because of a MIDI CC,
	// because if the host records both the MIDI CC automation and the parameter
	// automation there will be a conflict.
	DONT_RECORD = 1 << 1,
}

// Core event types
// Some of the following events overlap, a note on can be expressed with:
// - CLAP_EVENT_NOTE_ON
// - CLAP_EVENT_MIDI  
// - CLAP_EVENT_MIDI2
//
// The preferred way of sending a note event is to use CLAP_EVENT_NOTE_*.
// The same event must not be sent twice: it is forbidden to send the same note on
// encoded with both CLAP_EVENT_NOTE_ON and CLAP_EVENT_MIDI.
Event_Type :: enum u16 {
	NOTE_ON             = 0, // Note on event
	NOTE_OFF            = 1, // Note off event
	NOTE_CHOKE          = 2, // Note choke event (immediate stop)
	NOTE_END            = 3, // Note end event
	NOTE_EXPRESSION     = 4, // Note expression change
	PARAM_VALUE         = 5, // Parameter value change
	PARAM_MOD           = 6, // Parameter modulation
	PARAM_GESTURE_BEGIN = 7, // Parameter gesture begin
	PARAM_GESTURE_END   = 8, // Parameter gesture end
	TRANSPORT           = 9, // Transport information
	MIDI                = 10, // MIDI event
	MIDI_SYSEX          = 11, // MIDI System Exclusive
	MIDI2               = 12, // MIDI 2.0 event
}

// Event header - all clap events start with this header to determine the overall
// size of the event and its type and space (a namespacing for types).
// clap_event objects are contiguous regions of memory which can be copied
// with a memcpy of `size` bytes starting at the top of the header.
Event_Header :: struct {
	size:       u32, // event size including this header, eg: sizeof(Event_Note)
	time:       u32, // sample offset within the buffer for this event
	space_id:   u16, // event space, see clap_host_event_registry
	event_type: Event_Type, // event type
	flags:      Event_Flags, // see Event_Flags
}

// Input event list interface
Input_Events :: struct {
	ctx:  rawptr, // reserved pointer for the implementation
	// Get the number of events in the list
	size: proc "c" (list: ^Input_Events) -> u32,
	// Get event at specified index
	get:  proc "c" (list: ^Input_Events, index: u32) -> ^Event_Header,
}

// Output event list interface
Output_Events :: struct {
	ctx:      rawptr, // reserved pointer for the implementation
	// Try to push an event to the list. Returns true on success.
	// The plugin must insert events in sample sorted order.
	try_push: proc "c" (list: ^Output_Events, event: ^Event_Header) -> bool,
}

/////////////////
// Note Events //
/////////////////
Event_Note :: struct {
	header:     Event_Header,
	note_id:    i32,
	port_index: i16,
	channel:    i16,
	key:        i16,
	velocity:   f64,
}

Note_Expression_Type :: enum i32 {
	VOLUME     = 0,
	PAN        = 1,
	TUNING     = 2,
	VIBRATO    = 3,
	EXPRESSION = 4,
	BRIGHTNESS = 5,
	PRESSURE   = 6,
}

Event_Note_Expression :: struct {
	header:        Event_Header,
	expression_id: Note_Expression_Type,
	note_id:       i32,
	port_index:    i16,
	channel:       i16,
	key:           i16,
	value:         f64,
}

//////////////////////
// Parameter Events //
//////////////////////
Event_Param_Value :: struct {
	header:     Event_Header,
	param_id:   Clap_Id,
	cookie:     rawptr,
	note_id:    i32,
	port_index: i16,
	channel:    i16,
	key:        i16,
	value:      f64,
}

Event_Param_Mod :: struct {
	header:     Event_Header,
	param_id:   Clap_Id,
	cookie:     rawptr,
	note_id:    i32,
	port_index: i16,
	channel:    i16,
	key:        i16,
	amount:     f64,
}

Event_Param_Gesture :: struct {
	header:   Event_Header,
	param_id: Clap_Id,
}

//////////////////////
// Transport Events //
//////////////////////
Transport_Flags :: enum u32 {
	HAS_TEMPO            = 1 << 0,
	HAS_BEATS_TIMELINE   = 1 << 1,
	HAS_SECONDS_TIMELINE = 1 << 2,
	HAS_TIME_SIGNATURE   = 1 << 3,
	IS_PLAYING           = 1 << 4,
	IS_RECORDING         = 1 << 5,
	IS_LOOP_ACTIVE       = 1 << 6,
	IS_WITHIN_PRE_ROLL   = 1 << 7,
}

Event_Transport :: struct {
	header:             Event_Header,
	flags:              u32,
	song_pos_beats:     Beat_Time,
	song_pos_seconds:   Sec_Time,
	tempo:              f64,
	tempo_inc:          f64,
	loop_start_beats:   Beat_Time,
	loop_end_beats:     Beat_Time,
	loop_start_seconds: Sec_Time,
	loop_end_seconds:   Sec_Time,
	bar_start:          Beat_Time,
	bar_number:         i32,
	tsig_num:           i16,
	tsig_denum:         i16,
}

/////////////////
// MIDI Events //
/////////////////
Event_Midi :: struct {
	header:     Event_Header,
	port_index: u16,
	data:       [3]u8,
}

Event_Midi_Sysex :: struct {
	header:     Event_Header,
	port_index: u16,
	buffer:     [^]u8,
	size:       u32,
}

Event_Midi2 :: struct {
	header:     Event_Header,
	port_index: u16,
	data:       [4]u8,
}
