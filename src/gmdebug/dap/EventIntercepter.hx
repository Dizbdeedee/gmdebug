package gmdebug.dap;

import gmdebug.Cross.OUTPUT_INTERCEPTED;
#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end
import gmdebug.composer.EventString;
import js.node.ChildProcess;
import gmdebug.dap.OutputFilterer;
using StringTools;

interface EventIntercepter {
    function event(ceptedEvent:Event<Dynamic>, threadId:Int):EventResult;
}


class EventIntercepterDef implements EventIntercepter {

    final luaDebug:LuaDebugger;

    final outputFilterer:OutputFilterer;

    final fileTracker:FileTracker;

    public function new(_luaDebug:LuaDebugger,_outputFilterer:OutputFilterer,_fileTracker:FileTracker) {
        luaDebug = _luaDebug;
        outputFilterer = _outputFilterer;
        fileTracker = _fileTracker;
    }

    public function event(ceptedEvent:Event<Dynamic>, threadId:Int):EventResult {
        return switch ((ceptedEvent.event : EventString<Dynamic>)) {
            case loadedSource:
                final loadedEvent:LoadedSourceEvent = cast ceptedEvent;
                var sourceFound = loadedEvent.body.source.path;
                var context = threadId;
                trace(fileTracker.findAbsLuaFile(sourceFound,context));
                Send;
            case output:
                Send;
            case stopped:
                final stoppedEvent:StoppedEvent = cast ceptedEvent;
                if (luaDebug.initBundle.programs.xdotool && stoppedEvent.body.threadId > 0) {
                    trace("free my mousepointer please!!");
                    ChildProcess.execSync("setxkbmap -option grab:break_actions");
                    ChildProcess.execSync("xdotool key XF86Ungrab");
                }
                Send;
            default:
                Send;
        }
    }
}

enum EventResult {
    NoSend;
    Send;
}
