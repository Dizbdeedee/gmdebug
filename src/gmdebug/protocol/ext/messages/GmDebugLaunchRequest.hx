package gmdebug.protocol.ext.messages;

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

	?restartWithMapChange:Bool,

	?serverPort:String,

	?map:String,

	?lan:Bool,

	?gamemode:String,

	?noDebug:Bool
}
