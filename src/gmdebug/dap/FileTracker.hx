package gmdebug.dap;

using tink.CoreApi;
import haxe.io.Path as HxPath;
import node.Fs;

interface FileTracker {
    function storeFile(filePath:String,hash:String):Void;
    function storeLookupFile(filePath:String,hash:String):Void; //storeLookedupFile
    function lookupFile(filePath:String):LookupResult;
    function addLuaContext(directory:String,context:Int):Void;
    function findAbsLuaFile(filePath:String,context:Int):Option<String>;
}

enum LookupResult {
    NOT_STORED;
    CANT_FIND;
    SUPERIOR_FILE(path:String);
}

class FileTrackerDef implements FileTracker {

    var hashToSuperiorFile:Map<String,String> = [];
    var inferiorFileToHash:Map<String,String> = [];
    var contextStorage:Map<Int,String> = [];
    var existsCache:Map<String,Bool> = [];

    public function new() {}

    public function storeFile(filePath:String,hash:String) {
        trace('storeFile/ stored hash $hash');
        hashToSuperiorFile.set(hash,filePath);
    }

    public function storeLookupFile(path:String,hash:String) {
        inferiorFileToHash.set(path,hash);
    }

    public function lookupFile(path:String):LookupResult {
        var inferiorHash = inferiorFileToHash.get(path);
        return if (inferiorHash != null) {
            var superiorFile = hashToSuperiorFile.get(inferiorHash);
            if (superiorFile != null) {
                SUPERIOR_FILE(superiorFile);
            } else {
                trace('lookupFile/ our hash $inferiorHash');
                CANT_FIND;
            }
        } else {
            NOT_STORED;
        }
    }

    // return switch (inferiorFileToHash.get(path)) {
    //     case null:
    //         NOT_STORED;
    //     case hashToSuperiorFile.get(_) => null:
    //         trace('lookupFIle $hashToSuperiorFile');
    //         CANT_FIND;
    //     case hashToSuperiorFile.get(_) => superiorFile:
    //         SUPERIOR_FILE(superiorFile);
    // }

    public function addLuaContext(directory:String,context:Int) {
        contextStorage.set(context,directory);
    }

    public function findAbsLuaFile(luafilestring:String,context:Int):Option<String> {
        if (!contextStorage.exists(context)) {
            trace("findAbsLuaFile/ CONTEXT STORAGE DOES NOT EXIST!!");
            return None;
        }
        trace(contextStorage);
        trace(luafilestring);
        final cleanluafilestring = if (luafilestring.charAt(0) == "@") {
            luafilestring.substr(1);
        } else {
            luafilestring;
        }
        final absContextPath = contextStorage.get(context);
        final absLuaFilePath = HxPath.join([absContextPath,cleanluafilestring]);
        return if (existsCache.exists(absLuaFilePath)) {
            Some(absLuaFilePath);
        } else if (Fs.existsSync(absLuaFilePath)) {
            existsCache.set(absLuaFilePath,true);
            Some(absLuaFilePath);
        } else {
            trace('not exist $absLuaFilePath');
            None;
        }
    }

}