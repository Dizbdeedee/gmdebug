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
        var curFilePath = HxPath.join([curFolder,name]);
        var otherFile = HxPath.join([output,name]);
        if (FileSystem.isDirectory(curFilePath)) {
            if (!copyFilePred(HxPath.withoutDirectory(curFilePath))) continue;
            FileSystem.createDirectory(otherFile);
            recurseCopy(curFilePath,otherFile,copyFilePred);
        } else {
            var curFileName = HxPath.withoutExtension(HxPath.withoutDirectory(curFilePath));
            if (!copyFilePred(curFileName)) continue;
            HxFile.copy(curFilePath,otherFile);
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