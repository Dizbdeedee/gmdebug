package gmdebug.dap;

import js.node.Fs;
import gmdebug.Util.recurseCopy;

interface FileWatcher {
    function watch(initBundle:InitBundle):Void;
}

class FileWatcherDef implements FileWatcher {

    public function new() {}

    var stop = false;

    var copy = false;

    //windows only for now...
    public function watch(initBundle:InitBundle) {
        haxe.Timer.delay(copyTimeout.bind(initBundle),3000);
        Fs.watch(initBundle.luaAddon,{persistent: false,recursive: true},(eventType,fileName) -> {
            trace('$eventType $fileName');
            copy = true;
        });

    }

    function copyTimeout(initBundle:InitBundle) {
        if (stop) return;
        if (copy) {
            recurseCopy(initBundle.luaAddon,initBundle.luaAddonDestination,(file -> {trace(file); return file.charAt(0) != ".";}));
        }
        copy = false;
        haxe.Timer.delay(copyTimeout.bind(initBundle),3000);
    }
}