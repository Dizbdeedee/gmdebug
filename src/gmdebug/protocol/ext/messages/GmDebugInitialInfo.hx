package gmdebug.protocol.ext.messages;

typedef GmDebugInitialInfo = {
	/**
		Location. Can be server or client.
	**/
	location:String,

	?dapMode:DapModeStr,
	?autoLaunch:Bool
}

enum abstract DapModeStr(String) {
	var Attach;
	var Launch;
}
