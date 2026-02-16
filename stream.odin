package clap

///////////////
// Streams   //
///////////////
// When working with `Input_Stream` and `Output_Stream` objects to load and save
// state, it is important to keep in mind that the host may limit the number of
// bytes that can be read or written at a time. The return values for the
// stream read and write functions indicate how many bytes were actually read
// or written. You need to use a loop to ensure that you read or write the
// entirety of your state. Don't forget to also consider the negative return
// values for the end of file and IO error codes.

// Input stream interface
Input_Stream :: struct {
	ctx:  rawptr, // reserved pointer for the stream
	// returns the number of bytes read; 0 indicates end of file and -1 a read error
	read: proc "c" (stream: ^Input_Stream, buffer: rawptr, size: u64) -> i64,
}

// Output stream interface
Output_Stream :: struct {
	ctx:   rawptr, // reserved pointer for the stream
	// returns the number of bytes written; -1 on write error
	write: proc "c" (stream: ^Output_Stream, buffer: rawptr, size: u64) -> i64,
}
