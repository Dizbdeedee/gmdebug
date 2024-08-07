package gmdebug.protocol.ext.paths;

typedef PipeLocations = {
	folder:String, // folder
	client_ready:String, // client is ready to connect
	connect:String, // server says we've got that client ack
	pipes_ready:String, // pipes are ready - used
	input:String, // input pipe
	output:String, // output pipe
	client_ack:String, // lua writes this to say we're ready
	connection_in_progress:String, // not used
	connection_aquired:String, // lua writes this to say we've aquired
}