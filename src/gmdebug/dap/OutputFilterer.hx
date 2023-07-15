package gmdebug.dap;

import haxe.ds.Option;
import gmdebug.composer.ComposedEvent;
using StringTools;

interface OutputFilterer {
    function filter(source:FilterSource,msg:String):Option<ComposedEvent<Dynamic>>;
    function setFlags(flag:Array<FilterFilter>):Void;
}

enum FilterSource {
    CLIENT_CONSOLE(id:Int);
    CLIENT_LUA(id:Int);
    SERVER_CONSOLE;
    SERVER_LUA;
}

enum FilterFilter {
    CLIENT_CONSOLE(ids:Array<Int>);
    CLIENT_LUA(ids:Array<Int>);
    SERVER_CONSOLE;
    SERVER_LUA;
}

class OutputFiltererDef implements OutputFilterer {

    public function new() {}

    var flags = [null,CLIENT_LUA([]),SERVER_CONSOLE,SERVER_LUA];

    public function filter(source:FilterSource,msg:String):Option<ComposedEvent<Dynamic>> {
        if (!shouldPublish(source)) return None;
        var newmsg = switch (handleOutputIntercept(source,msg)) {
            case Some(newmsg):
                newmsg;
            case None:
                return None;
        }
        var outputBuf = new StringBuf();
        switch (source) {
            case CLIENT_CONSOLE(id) | CLIENT_LUA(id):
                outputBuf.add("[C");
                outputBuf.add(id);
                outputBuf.add("] - ");
            case SERVER_CONSOLE | SERVER_LUA:
                outputBuf.add("[S] - ");
        }
        outputBuf.add(newmsg);
        outputBuf.add("\n");
        return Some(new ComposedEvent(output,{
            category: Stdout,
            output: outputBuf.toString(),
            data: null
        }));
    }

    function handleOutputIntercept(source:FilterSource,msg:String):Option<String> {
        if (!msg.contains(Cross.OUTPUT_INTERCEPTED)) return Some(msg);
        var newmsg = msg.replace(Cross.OUTPUT_INTERCEPTED,"");
        switch [source,flags] {
            case [CLIENT_CONSOLE(_),[_,null,_,_]]:
                return Some(newmsg);
            default:
        }
        switch [source,flags] {
            case [SERVER_CONSOLE,[_,_,null,_]]:
                return Some(newmsg);
            default:
        }
        return None;

    }

    function shouldPublish(source:FilterSource) {
        switch [source,flags] {
            case [CLIENT_CONSOLE(id),[CLIENT_CONSOLE(filters),_,_,_]]:
                return if (filters.contains(id)) {
                    false;
                } else {
                    true;
                }
            default:
        }
        switch [source,flags] {
            case [CLIENT_LUA(id),[_,CLIENT_LUA(filters),_,_]]:
                return if (filters.contains(id)) {
                    false;
                } else {
                    true;
                }
            default:
        }
        switch [source,flags] {
            case [SERVER_CONSOLE,[_,_,SERVER_CONSOLE,_]]:
                return true;
            default:
        }
        switch [source,flags] {
            case [SERVER_LUA,[_,_,_,SERVER_LUA]]:
                return true;
            default:
        }
        return false;
    }

    public function setFlags(arr:Array<FilterFilter>) {
        flags = arr;
    }

}