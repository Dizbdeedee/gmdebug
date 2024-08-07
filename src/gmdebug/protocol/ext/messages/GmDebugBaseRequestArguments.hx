package gmdebug.protocol.ext.messages;

typedef GmDebugBaseRequestArguments = {
	/**
		REQUIRED The path to the servers "garrysmod" folder. Must be fully qualified.
	**/
	serverFolder:String,

	/**
		The path to client "garrysmod" folder. Must be fully qualified.
	**/
	?clientFolder:String
}

