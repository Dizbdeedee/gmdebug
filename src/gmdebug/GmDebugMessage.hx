package gmdebug;

#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end

typedef GmDebugMessage<T> = ProtocolMessage & {
	// type : String,
	msg:GmMsgType<T>,
	body:T
}

enum abstract GmMsgType<T>(Int) to Int {
	var playerAdded:GmMsgType<GMPlayerAddedMessage>;
	var playerRemoved:GmMsgType<GMPlayerRemovedMessage>;
	var clientID:GmMsgType<GMClientID>;
	var intialInfo:GmMsgType<GmDebugIntialInfo>;
	var serverInfo:GmMsgType<GMServerInfoMessage>;
}

enum abstract DapModeStr(String) {
	var Attach;
	var Launch;
}

typedef GmDebugIntialInfo = {
	/**
		Location. Can be server or client.
	**/
	location:String,

	?dapMode:DapModeStr,
	?autoLaunch:Bool
}

typedef GMPlayerAddedMessage = {
	/** ID of client. **/
	playerID:Int,

	/** name of client **/
	name:String
}

typedef GMPlayerRemovedMessage = {
	/** ID of client **/
	playerID:Int
}

typedef GMClientID = {
	/**
		Thread number given
	**/
	id:Int
}

typedef GMServerInfoMessage = {
	ip:String,

	isLan:Bool
}

typedef GmDebugAttachRequest = Request<GmDebugAttachRequestArguments>;

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

typedef GmDebugAttachRequestArguments = AttachRequestArguments & GmDebugBaseRequestArguments;
typedef GmDebugLaunchRequest = Request<GmDebugLaunchRequestArguments>;

typedef GmDebugLaunchRequestArguments = LaunchRequestArguments &
	GmDebugBaseRequestArguments & {
	/**
		REQUIRED The path to batch file or script used to launch your server
	**/
	programPath:String,

	?programArgs:Array<String>,
	/**
		If you wish to log the output.
	**/
	?fileOutput:String,
	/**
		Should the dap automatically connect your steam instance to the server?
	**/
	?autoConnectLocalGmodClient:Bool,

	/**
		Number of clients
	**/
	?clients:Int,

	?multirunOptions:Array<String>,

	/**
		Friendly friend reminder for friends
	**/
	?nodebugClient:Bool,

	/**
		Copy everything inside specifed folder to addons/{addonName} (also a parameter)
	**/
	?copyAddonBaseFolder:String,

	/**Give it a name...**/
	?copyAddonName:String,

	/**Ect. ect.**/
	?noCopy:Bool,

	?serverPort:String,

	?noDebug:Bool
}
