package gmdebug.dap;

import haxe.ds.Option;
import gmdebug.composer.ComposedEvent;
using StringTools;

interface OutputFilterer {
    function filter(source:FilterSource,msg:String):Option<ComposedEvent<Dynamic>>;
    function setFlags(flag:Array<FilterFilterFilter>):Void;
}

enum FilterSource {
    CLIENT_CONSOLE(id:Int);
    CLIENT_LUA(id:Int);
    SERVER_CONSOLE;
    SERVER_LUA;
}

enum FilterFilterFilter {
    ACTIVE(fl:FilterFilter);
    NOT_ACTIVE(fl:FilterFilter);
}
enum FilterFilter {
    CLIENT_CONSOLE(ids:Array<Int>);
    CLIENT_LUA(ids:Array<Int>);
    SERVER_CONSOLE;
    SERVER_LUA;
}

class OutputFiltererDef implements OutputFilterer {

    public function new() {}

    var flags = [NOT_ACTIVE(CLIENT_CONSOLE(null)),NOT_ACTIVE(CLIENT_LUA(null)),ACTIVE(SERVER_CONSOLE),ACTIVE(SERVER_LUA)];

    public function filter(source:FilterSource,msg:String):Option<ComposedEvent<Dynamic>> {
        if (!shouldPublish(source)) return None;
        var newmsg = switch (handleOutputIntercept(source,msg)) {
            case Some(newmsg):
                newmsg;
            case None:
                return None;
        }
        var outputBuf = new StringBuf();
        outputBuf.add(newmsg);
        return Some(new ComposedEvent(output,consoleSource(source,outputBuf)));
    }

    function consoleSource(source:FilterSource,outputbuf:StringBuf):TOutputEvent {
        switch source {
            case CLIENT_CONSOLE(id):
                return {
                    category: Stdout,
                    output: outputbuf.toString(),
                    source: {
                        name: 'client_console_$id'
                    },
                    data: null
                }
            case SERVER_CONSOLE:
                return {
                    category: Stdout,
                    output: outputbuf.toString(),
                    source: {
                        name: "server_console"
                    },
                    data: null
                }
            default:
                return {
                    category: Stdout,
                    output: outputbuf.toString(),
                    data: null
                }
        }
    }

    function handleOutputIntercept(source:FilterSource,msg:String):Option<String> {
        if (!msg.contains(Cross.OUTPUT_INTERCEPTED)) return Some(msg);
        var newmsg = msg.replace(Cross.OUTPUT_INTERCEPTED,"");
        // we want to print the intercepted messages if we aren't displaying the cleaned output version
        switch [source,flags] {
            case [CLIENT_CONSOLE(_),[_,NOT_ACTIVE(CLIENT_LUA(_)),_,_]]:
                return Some(newmsg);
            default:
        }
        switch [source,flags] {
            case [SERVER_CONSOLE,[_,_,_,NOT_ACTIVE(SERVER_LUA)]]: //SEE! I GOT IT WRONG
                return Some(newmsg);
            default:
        }
        return None;

    }

    function shouldPublish(source:FilterSource) {
        switch [source,flags] {
            case [CLIENT_CONSOLE(id),[ACTIVE(CLIENT_CONSOLE(filters)),_,_,_]]:
                return if (filters.contains(id)) {
                    false;
                } else {
                    true;
                }
            default:
        }
        switch [source,flags] {
            case [CLIENT_LUA(id),[_,ACTIVE(CLIENT_LUA(filters)),_,_]]:
                return if (filters.contains(id)) {
                    false;
                } else {
                    true;
                }
            default:
        }
        switch [source,flags] {
            case [SERVER_CONSOLE,[_,_,ACTIVE(SERVER_CONSOLE),_]]:
                return true;
            default:
        }
        switch [source,flags] {
            case [SERVER_LUA,[_,_,_,ACTIVE(SERVER_LUA)]]:
                return true;
            default:
        }
        return false;
    }

    public function setFlags(arr:Array<FilterFilterFilter>) {
        flags = arr;
    }

}