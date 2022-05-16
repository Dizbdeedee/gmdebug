package gmdebug.dap;

import js.node.Fs;
import haxe.io.Path as HxPath;

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