package gmdebug;

import sys.FileSystem;
import haxe.io.Path as HxPath;
import sys.io.File as HxFile;

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