package clap

// Audio buffer structure for processing audio data
//
// Sample code for reading a stereo buffer:
//
// is_left_constant := (buffer.constant_mask & (1 << 0)) != 0
// is_right_constant := (buffer.constant_mask & (1 << 1)) != 0
//
// for i in 0..<N {
//    l := buffer.data32[0][is_left_constant ? 0 : i]
//    r := buffer.data32[1][is_right_constant ? 0 : i]
// }
//
// Note: checking the constant mask is optional, and this implies that
// the buffer must be filled with the constant value.
// Rationale: if a buffer reader doesn't check the constant mask, then it may
// process garbage samples and in result, garbage samples may be transmitted
// to the audio interface with all the bad consequences it can have.
//
// The constant mask is a hint.
Audio_Buffer :: struct {
	// Either data32 or data64 pointer will be set.
	data32:        [^][^]f32, // 32-bit floating point audio data
	data64:        [^][^]f64, // 64-bit floating point audio data
	channel_count: u32, // Number of audio channels
	latency:       u32, // Latency from/to the audio interface
	constant_mask: u64, // Bitmask indicating which channels contain constant values
}
