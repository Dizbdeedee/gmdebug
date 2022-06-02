package gmdebug.dap;
typedef InitBundle {
    serverFolderResult : String,
    requestArguments : String,
    serverFolder : String,
    programPath : String,
    p
}
class InitBundle {



    function new() {

    }

    public static function initBundle(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments):Result<InitBundle> {
        final initBundle = new InitBundle();
        final serverFolderResult = validateServerFolder(args.serverFolder);
		requestArguments = args;
		if (serverFolderResult != None) {
			serverFolderResult.sendError(req,this);
			return;
		}
		final serverSlash = HxPath.addTrailingSlash(args.serverFolder);
		serverFolder = serverSlash;
		var programPath = switch (args.programPath) {
			case null:
				req.composeFail("Gmdebug requires the property \"programPath\" to be specified when launching.", {
					id: 2,
					format: "Gmdebug requires the property \"programPath\" to be specified when launching",
				}).send(this);
				return;
			case "auto":
				if (Sys.systemName() == "Windows") {
					'$serverFolder/../srcds.exe';
				} else {
					'$serverFolder/../srcds_run';
				}
			case path:
				path;
		}
		if (!HxPath.isAbsolute(programPath)) {
			programPath = HxPath.join([serverFolder,programPath]);
		}
		final programPathResult = validateProgramPath(programPath);
		if (programPathResult != None) {
			programPathResult.sendError(req,this);
			return;
		}
		shouldAutoConnect = args.autoConnectLocalGmodClient.or(false);
		var childProcess = new LaunchProcess(programPath,this,args.programArgs);
		if (args.noDebug) {
			dapMode = LAUNCH(childProcess);
			serverFolder = HxPath.addTrailingSlash(args.serverFolder);
			final comp = (req : LaunchRequest).compose(launch,{});
			comp.send(this);
			return;
		}
		generateInitFiles(serverFolder);
		copyLuaFiles(serverFolder);
		var clientFolder = args.clientFolder;
		if (clientFolder != null) {
			final clientFolderResult = validateClientFolder(clientFolder);
			if (clientFolderResult != None) {
				clientFolderResult.sendError(req,this);
				return;
			}
			clientFolder = HxPath.addTrailingSlash(clientFolder);
		}
		setClientLocation(clientFolder);
		dapMode = LAUNCH(childProcess);
		startServer(req);

    }
}