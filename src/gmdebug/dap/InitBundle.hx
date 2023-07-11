package gmdebug.dap;

import gmdebug.Cross.PATH_FOLDER;
import gmdebug.Cross.PATH_DATA;
import gmdebug.Cross.PATH_ADDONS;
import js.node.Fs;
using tink.CoreApi;
import gmdebug.dap.LuaDebugger.Programs;
import gmdebug.GmDebugMessage.GmDebugLaunchRequestArguments;
import haxe.io.Path as HxPath;
using gmdebug.composer.ComposeTools;

class InitBundleException extends haxe.Exception {}

class InitBundle {

    public final serverFolder:String;

    public final programs:Programs = {
        xdotool: false
    };

    public final shouldAutoConnect:Bool = false;

    public final requestArguments:Null<GmDebugLaunchRequestArguments>;

    public final clientLocation:Option<String>;

    public final programPath:String;

    public final argString:String;

    public final luaAddonDestination:String;

    public final luaAddon:String;

    public final addonName:String;

    public final serverAddonFolder:String;

    public final serverPort:String;

    public final noDebug:Bool;

    public final clients:Option<Int>;

    function new(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments,luadebug:LuaDebugger) {
        requestArguments = args;

        switch (validateServerFolder(args.serverFolder)) {
            case Error(id, variables):
                req.composeFail(id,variables).send(luadebug);
                throw new InitBundleException("Could not validate serverfolder");
            default:
        }
        final serverSlash = HxPath.addTrailingSlash(args.serverFolder);
        serverFolder = serverSlash;

        if (!args.nodebugClient && args.clientFolder == null) {
            req.composeFail(DEBUGGER_INVALID_CLIENTFOLDER_UNSPECIFIED).send(luadebug);
            throw new InitBundleException("Debugging clients requested but no clientFolder specified");
        }
        if (args.copyAddonBaseFolder != null && HxPath.isAbsolute(args.copyAddonBaseFolder)) {
            req.composeFail(DEBUGGER_INVALID_COPYFOLDER_ABSOLUTE).send(luadebug);
            throw new InitBundleException("CopyAddonBaseFolder is a relative path, copying your active lua development files");
        }
        if (!args.noCopy && (args.copyAddonName == null || args.copyAddonBaseFolder == null)) {
            req.composeFail(DEBUGGER_INVALID_COPYFOLDER).send(luadebug);
            throw new InitBundleException("Copying requested but no addonName/copyAddonBaseFolder");
        }
        programPath = switch (args.programPath) {
            case null:
                req.composeFail(DEBUGGER_INVALID_PROGRAMPATH_UNSPECIFIFED).send(luadebug);
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

        switch (validateProgramPath(programPath)) {
            case Error(id, variables):
                req.composeFail(id,variables).send(luadebug);
                throw new InitBundleException("Could not validate programPath");
            default:
        }
        shouldAutoConnect = args.autoConnectLocalGmodClient.or(false);

        clientLocation = switch(args.clientFolder) {
            case null:
                None;
            case validateClientFolder(_) => Error(id, variables):
                req.composeFail(id,variables);
                throw new InitBundleException("Could not validate client folder");
            case validateClientFolder(_) => None:
                Some(args.clientFolder);
        }

        var programArgs = args.programArgs.or([]);
        argString = programArgs.join(" ");

        var relative = args.copyAddonBaseFolder;
        luaAddon = HxPath.join([luadebug.workspaceFolder,relative]);

        addonName = args.copyAddonName;
        luaAddonDestination = HxPath.join([serverFolder,"addons",addonName]);

        serverAddonFolder = HxPath.join([serverFolder,"addons"]);

        serverPort = args.serverPort.or("27115");

        noDebug = args.noDebug.or(false);

        clients = if (args.nodebugClient) {
            None;
        } else if (args.clients == null) {
            None;
        } else {
            Some(args.clients);
        }
    }


    public static function initBundle(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments,luadebug:LuaDebugger):Outcome<InitBundle,InitBundleException> {
        return try {
            final initBundleAttempt = new InitBundle(req, args, luadebug);
            Success(initBundleAttempt);
        } catch (e:InitBundleException) {
            Failure(e);
        }
    }

    function validateProgramPath(programPath:String):InitError {
        return if (programPath == null) {
            Error(DEBUGGER_INVALID_PROGRAMPATH_UNSPECIFIFED);
        } else if (!Fs.existsSync(programPath)) {
            Error(DEBUGGER_INVALID_PROGRAMPATH_NOTEXIST);
        } else if (!Fs.statSync(programPath).isFile()) {
            Error(DEBUGGER_INVALID_PROGRAMPATH_NOTFILE);
        } else {
            None;
        }
    }

    function validateServerFolder(serverFolder:String):InitError {
        return if (serverFolder == null) {
            Error(DEBUGGER_INVALID_SERVERFOLDER_UNSPECIFIED);
        } else {
            final addonFolder = js.node.Path.join(serverFolder, PATH_ADDONS);
            if (!HxPath.isAbsolute(serverFolder)) {
                Error(DEBUGGER_INVALID_SERVERFOLDER_NOTABSOLUTE);
            } else if (!Fs.existsSync(serverFolder)) {
                Error(DEBUGGER_INVALID_SERVERFOLDER_NOTEXIST);
            } else if (!Fs.statSync(serverFolder).isDirectory()) {
                Error(DEBUGGER_INVALID_SERVERFOLDER_NOTDIR);
            } else if (!Fs.existsSync(addonFolder) || !Fs.statSync(addonFolder).isDirectory()) {
                Error(DEBUGGER_INVALID_SERVERFOLDER_NOTGMOD);
            } else {
                None;
            }
        }
    }

    function validateClientFolder(folder:String):InitError {
        final addonFolder = js.node.Path.join(folder, PATH_ADDONS);
        final gmdebug = js.node.Path.join(folder, PATH_DATA, PATH_FOLDER);
        return if (!HxPath.isAbsolute(folder)) {
            Error(DEBUGGER_INVALID_CLIENTFOLDER_NOTABSOLUTE,{folder : folder});
        } else if (!Fs.existsSync(folder)) {
            Error(DEBUGGER_INVALID_CLIENTFOLDER_NOTEXIST,{folder : folder});
        } else if (!Fs.statSync(folder).isDirectory()) {
            Error(DEBUGGER_INVALID_CLIENTFOLDER_NOTDIR,{folder : folder});
        } else if (!Fs.existsSync(addonFolder) || !Fs.statSync(addonFolder).isDirectory()) {
            Error(DEBUGGER_INVALID_CLIENTFOLDER_NOTGMOD, {folder : folder});
        } else {
            None;
        }
    }
}

@:using(gmdebug.dap.InitBundle.InitErrorUsing)
private enum InitError {
    None;
    Error(id:GmDebugError,?variables:{});
}

class InitErrorUsing {
    public static function sendError(err:InitError,req:Request<Dynamic>,luadebug:LuaDebugger) {
        switch (err) {
            case Error(id, variables):
                req.composeFail(id,variables);
            case None:
        }
    }
}
