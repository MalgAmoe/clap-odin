package clap

import "core:math"

// Fixed point representation of beat time and seconds time
// Usage:
//   x: f64 = ...  // in beats
//   y: Beat_Time = Beat_Time(round(BEATTIME_FACTOR * x))

// These values will never change
BEATTIME_FACTOR :: 1 << 31
SECTIME_FACTOR :: 1 << 31

// Fixed point time types
Beat_Time :: distinct i64 // clap_beattime
Sec_Time :: distinct i64 // clap_sectime

// Conversion helpers
beats_to_fixed :: proc(beats: f64) -> Beat_Time {
	return Beat_Time(math.round(BEATTIME_FACTOR * beats))
}

fixed_to_beats :: proc(fixed: Beat_Time) -> f64 {
	return f64(fixed) / BEATTIME_FACTOR
}

seconds_to_fixed :: proc(seconds: f64) -> Sec_Time {
	return Sec_Time(math.round(SECTIME_FACTOR * seconds))
}

fixed_to_seconds :: proc(fixed: Sec_Time) -> f64 {
	return f64(fixed) / SECTIME_FACTOR
}
