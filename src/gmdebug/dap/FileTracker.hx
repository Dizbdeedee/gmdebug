package gmdebug.dap;

using tink.CoreApi;
import haxe.io.Path as HxPath;
import node.Fs;

interface FileTracker {
    function storeFile(filePath:String,hash:String):Void;
    function storeLookupFile(filePath:String,hash:String):Void;
    function lookupFile(filePath:String):Option<String>;
    function addLuaContext(directory:String,context:Int):Void;
    function findAbsLuaFile(filePath:String,context:Int):Option<String>;
}

class FileTrackerDef implements FileTracker {

    var hashToSuperiorFile:Map<String,String> = [];
    var inferiorFileToHash:Map<String,String> = [];
    var contextStorage:Map<Int,String> = [];

    public function new() {}

    public function storeFile(filePath:String,hash:String) {
        hashToSuperiorFile.set(hash,filePath);
    }

    public function storeLookupFile(path:String,hash:String) {
        inferiorFileToHash.set(path,hash);
    }

    public function lookupFile(path:String):Option<String> {
        return switch (inferiorFileToHash.get(path)) {
            case null:
                None;
            case hashToSuperiorFile.get(_) => null:
                None;
            case hashToSuperiorFile.get(_) => superiorFile:
                Some(superiorFile);
        }
    }

    public function addLuaContext(directory:String,context:Int) {
        contextStorage.set(context,directory);
    }

    public function findAbsLuaFile(luafilestring:String,context:Int):Option<String> {
        if (!contextStorage.exists(context)) {
            trace("findAbsLuaFile/ CONTEXT STORAGE DOES NOT EXIST!!");
            return None;
        }
        final cleanluafilestring = if (luafilestring.charAt(0) == "@") {
            luafilestring.substr(1);
        } else {
            luafilestring;
        }
        final absContextPath = contextStorage.get(context);
        final absLuaFilePath = HxPath.join([absContextPath,cleanluafilestring]);
        return if (Fs.existsSync(absLuaFilePath)) {
            Some(absLuaFilePath);
        } else {
            trace('not exist $absLuaFilePath');
            None;
        }
    }

}