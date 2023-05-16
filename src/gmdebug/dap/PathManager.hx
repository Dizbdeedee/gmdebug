package gmdebug.dap;

import js.node.Fs;
import tink.core.Option;
import js.node.Path as NPath;
using StringTools;

interface PathManager {
    final clientFolderOpt:Option<String>;
    final activeLuaFolderOpt:Option<String>;
    final serverFolder:String;

    function gmodPathToRealPath(_gmodPath:String):String;
    function realPathToGmodPath(_realPath:String):String;

}



class PathManagerDef implements PathManager {

    public final serverFolder:String;

    public final clientFolderOpt:Option<String> = None;

    public final activeLuaFolderOpt:Option<String> = None;

    public function new(_serverFolder:String,?_activeLuaFolder:String,?_clientFolder:String) {
        serverFolder = convertPath(_serverFolder);
        clientFolderOpt = if (_clientFolder == null) {
            None;
        } else {
            Some(convertPath(_clientFolder));
        }
        activeLuaFolderOpt = if (_activeLuaFolder == null) {
            None;
        } else {
            Some(convertPath(_activeLuaFolder));
        }
    }

    function convertPath(str:String):String {
        return str.split(NPath.sep).join(NPath.posix.sep);
    }

    public function gmodPathToRealPath(_gmodPath:String) {
        var gmodPath = _gmodPath.substr(1);
       
        switch (activeLuaFolderOpt) {
            case Some(activeLuaFolder):
                var tryLuaFolder = NPath.join(activeLuaFolder,gmodPath);
                if (Fs.existsSync(tryLuaFolder)) {
                    return tryLuaFolder;
                }
            default:
        }
        var tryServerFolder = NPath.join(serverFolder,gmodPath);
        if (Fs.existsSync(tryServerFolder)) {
            return tryServerFolder;
        }
        return gmodPath;
        
    }

    public function realPathToGmodPath(realPath:String):String {
        var realPathPosix = convertPath(realPath);
        var gmodPath = switch [realPathPosix.contains(serverFolder),clientFolderOpt,
            activeLuaFolderOpt] {
            case [true,_,_]:
                realPathPosix.replace(serverFolder,"");
            case [_,Some(clientFolder),_] if (realPathPosix.contains(clientFolder)):
                realPathPosix.replace(clientFolder,"");
            case [_,_,Some(activeLuaFolder)] if (realPathPosix.contains(activeLuaFolder)):
                realPathPosix.replace(activeLuaFolder,"");
            default:
                realPathPosix;
        }
        return '@$gmodPath';
    }

}