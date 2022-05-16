package gmdebug;

#if macro
import haxe.macro.Context;
#end
import sys.FileSystem;
import haxe.io.Path as HxPath;
import sys.io.File as HxFile;
using Lambda;
using StringTools;
function recurseCopy(curFolder:String,output:String,copyFilePred:(String) -> Bool) {
    for (name in FileSystem.readDirectory(curFolder)) {
        var curFile = HxPath.join([curFolder,name]);
        var otherFile = HxPath.join([output,name]);
        if (FileSystem.isDirectory(HxPath.join([curFolder,name]))) {
            FileSystem.createDirectory(otherFile);
            recurseCopy(HxPath.join([curFolder,name]),HxPath.join([output,name]),copyFilePred);
        } else {
            final curname = HxPath.withoutExtension(HxPath.withoutDirectory(curFile));
            if (copyFilePred(curname)) {
                HxFile.copy(curFile,otherFile);
            }
        }
    }
}

macro function embedResource(name:String) {
    for (str in Sys.args()) {
        final start = str.indexOf('@$name');
        if (start > 0) {
            final path = str.substr(0,start);
            Context.registerModuleDependency(Context.getLocalModule(),path); //is it the placebo effect? either way. it makes me feel better
        }
    }
    return macro $v{haxe.Resource.getString(name)};
}