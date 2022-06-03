package gmdebug.dap;

import js.node.Fs;
using tink.CoreApi;
import gmdebug.dap.LuaDebugger.Programs;
import gmdebug.GmDebugMessage.GmDebugLaunchRequestArguments;
import haxe.io.Path as HxPath;
using gmdebug.composer.ComposeTools;
using gmdebug.dap.DapFailure;


class InitBundleException extends haxe.Exception {}

class InitBundle {

	public final serverFolder:String;

	public final programs:Programs = {
		xdotool: false
	};

	public final shouldAutoConnect:Bool = false;

	public final requestArguments:Null<GmDebugLaunchRequestArguments>;

	public final clientLocation:String;

	public final programPath:String;

	public final programArgs:Null<Array<String>>;
	

    function new(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments,luadebug:LuaDebugger) {

        final serverFolderResult = validateServerFolder(args.serverFolder);
		requestArguments = args;
		if (serverFolderResult != None) {
			serverFolderResult.sendError(req,luadebug);
			throw new InitBundleException("Could not validate serverfolder");
		}
		final serverSlash = HxPath.addTrailingSlash(args.serverFolder);
		serverFolder = serverSlash;
		if (!args.nodebugClient && args.clientFolder == null) {
			req.composeFail({
				id: 2,
				format: "If you wish to debug clients, you must specify clientFolder first, or add the option nodebugClient into your launch options",
			}).send(luadebug);
			throw new InitBundleException("Debugging clients requested but no clientFolder specified");
		}
		if (!args.noCopy && args.addonName == null || args.addonFolderBase == null) {
			req.composeFail({
				id: 2,
				format: "If you wish to copy your addon to the server on debug, specify both addonName and addonFolderBase or add the option noCopy into your launch options",
			}).send(luadebug);
			throw new InitBundleException("Copying requested but no addonName/addonFolderBase");
		}
		programPath = switch (args.programPath) {
			case null:
				req.composeFail({
					id: 2,
					format: "Gmdebug requires the property \"programPath\" to be specified when launching",
				}).send(luadebug);
				throw new InitBundleException("Program path property does not exist");
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
			programPathResult.sendError(req,luadebug);
			throw new InitBundleException("Could not validate programPath");
		}
		shouldAutoConnect = args.autoConnectLocalGmodClient.or(false);
		var clientFolder = args.clientFolder;
		if (clientFolder != null) {
			final clientFolderResult = validateClientFolder(clientFolder);
			if (clientFolderResult != None) {
				clientFolderResult.sendError(req,luadebug);
				throw new InitBundleException("Could not validate client folder");
			}
			clientFolder = HxPath.addTrailingSlash(clientFolder);
		}
		clientLocation = clientFolder;
		programArgs = args.programArgs;
    }


    public static function initBundle(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments,luadebug:LuaDebugger):Outcome<InitBundle,InitBundleException> {
        return try {
			final initBundleAttempt = new InitBundle(req, args, luadebug);
			Success(initBundleAttempt);
		} catch (e:InitBundleException) {
			Failure(e);
		}

    }

	function validateProgramPath(programPath:String):haxe.ds.Option<DapFailure> {
		return if (programPath == null) {
			Some({
				id : 2,
				message : "Gmdebug requires the property \"programPath\" to be specified when launching"
			});
		} else {
		
			if (!Fs.existsSync(programPath)) {
				Some({
					id : 4,
					message : "The program specified by \"programPath\" does not exist!"
				});
			} else if (!Fs.statSync(programPath).isFile()) {
				Some({
					id : 5,
					message : "The program specified by \"programPath\" is not a file."
				});
			} else {
				None;
			}
		}
	
	}
	
	function validateServerFolder(serverFolder:String):haxe.ds.Option<DapFailure> {
		return if (serverFolder == null) {
			Some({
				id : 2,
				message : "Gmdebug requires the property \"serverFolder\" to be specified."
			});
		} else {
			final addonFolder = js.node.Path.join(serverFolder, "addons");
			if (!HxPath.isAbsolute(serverFolder)) {
				Some({
					id : 3,
					message : "Gmdebug requires the property \"serverFolder\" to be an absolute path (i.e from root folder)."
				});
			} else if (!Fs.existsSync(serverFolder)) {
				Some({
					id : 4,
					message : "The \"serverFolder\" path does not exist!"
				});
			} else if (!Fs.statSync(serverFolder).isDirectory()) {
				Some({
					id : 5,
					message : "The \"serverFolder\" path is not a directory."
				});
			} else if (!Fs.existsSync(addonFolder) || !Fs.statSync(addonFolder).isDirectory()) {
				Some({
					id : 6,
					message : "\"serverFolder\" does not seem to be a garrysmod directory. (looking for \"addons\" folder)"
				});
			} else {
				None;
			}
		}
	}
	
	function validateClientFolder(folder:String):haxe.ds.Option<DapFailure> {
		final addonFolder = js.node.Path.join(folder, "addons");
		final gmdebug = js.node.Path.join(folder, "data", "gmdebug");
		return if (!HxPath.isAbsolute(folder)) {
			Some({
				id : 8,
				message : 'Gmdebug requires client folder: $folder to be an absolute path (i.e from root folder).'
			});
		} else if (!Fs.existsSync(folder)) {
			Some({
				id : 9,
				message : 'The client folder: $folder does not exist!'
			});
		} else if (!Fs.statSync(folder).isDirectory()) {
			Some({
				id : 10,
				message : 'The client folder: $folder is not a directory.'
			});
		} else if (!Fs.existsSync(addonFolder) || !Fs.statSync(addonFolder).isDirectory()) {
			Some({
				id : 11,
				message : 'The client folder: $folder does not seem to be a garrysmod directory. (looking for \"addons\" folder)'
			});
		} else {
			None;
		}
	}
}