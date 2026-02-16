package clap

// The clap core event space
CORE_EVENT_SPACE_ID : u16 : 0

// Event flags for additional event metadata (bitmask, OR-able)
EVENT_IS_LIVE     :: 1 << 0 // Live user event, e.g. turning a physical knob or playing a key
EVENT_DONT_RECORD :: 1 << 1 // Event should not be recorded (e.g. from MIDI CC that's already recorded)

// Core event types. The event type space is extensible via clap_host_event_registry.
// The preferred way of sending a note event is to use EVENT_NOTE_*.
// The same event must not be sent twice: it is forbidden to send the same note on
// encoded with both EVENT_NOTE_ON and EVENT_MIDI.
EVENT_NOTE_ON             : u16 : 0
EVENT_NOTE_OFF            : u16 : 1
EVENT_NOTE_CHOKE          : u16 : 2
EVENT_NOTE_END            : u16 : 3
EVENT_NOTE_EXPRESSION     : u16 : 4
EVENT_PARAM_VALUE         : u16 : 5
EVENT_PARAM_MOD           : u16 : 6
EVENT_PARAM_GESTURE_BEGIN : u16 : 7
EVENT_PARAM_GESTURE_END   : u16 : 8
EVENT_TRANSPORT           : u16 : 9
EVENT_MIDI                : u16 : 10
EVENT_MIDI_SYSEX          : u16 : 11
EVENT_MIDI2               : u16 : 12

// Event header - all clap events start with this header to determine the overall
// size of the event and its type and space (a namespacing for types).
// clap_event objects are contiguous regions of memory which can be copied
// with a memcpy of `size` bytes starting at the top of the header.
Event_Header :: struct {
	size:       u32, // event size including this header, eg: sizeof(Event_Note)
	time:       u32, // sample offset within the buffer for this event
	space_id:   u16, // event space, see clap_host_event_registry
	event_type: u16, // event type, see Event_Type
	flags:      u32, // see Event_Flags
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
// Transport flags (bitmask, OR-able)
TRANSPORT_HAS_TEMPO            :: 1 << 0
TRANSPORT_HAS_BEATS_TIMELINE   :: 1 << 1
TRANSPORT_HAS_SECONDS_TIMELINE :: 1 << 2
TRANSPORT_HAS_TIME_SIGNATURE   :: 1 << 3
TRANSPORT_IS_PLAYING           :: 1 << 4
TRANSPORT_IS_RECORDING         :: 1 << 5
TRANSPORT_IS_LOOP_ACTIVE       :: 1 << 6
TRANSPORT_IS_WITHIN_PRE_ROLL   :: 1 << 7

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
	tsig_num:           u16,
	tsig_denom:         u16,
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
	data:       [4]u32,
}
