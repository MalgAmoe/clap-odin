package clap

// This type defines a timestamp: the number of seconds since UNIX EPOCH.
// See C's time_t time(time_t *).
Timestamp :: distinct u64

// Value for unknown timestamp.
TIMESTAMP_UNKNOWN :: Timestamp(0)
