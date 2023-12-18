import haxe.macro.Context;
import sys.io.File;
import sys.FileSystem;
using StringTools;

class Fixup {

    public static function main() {
        var fileArg = Context.definedValue("file");
        trace(fileArg);
        var regexArg = Context.definedValue("regex");
        var replaceArg = Context.definedValue("replace");
        var content = File.getContent(fileArg);
        #if useRegex
        var regexp = new EReg(regexArg,"g");
        var newContent = regexp.replace(content,replaceArg);
        #else
        var newContent = StringTools.replace(content,regexArg,replaceArg);
        #end
        File.saveContent(fileArg,newContent);
        
    }

}