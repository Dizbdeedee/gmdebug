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
import node.Fs;
import node.NodeCrypto;
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
                final outputEvent:OutputEvent = cast ceptedEvent;
                var source = outputEvent.body.source;
                if (source != null) {
                    var pth = source.path;
                    if (pth != null) {
                        final newPth = switch (fileTracker.findAbsLuaFile(pth,threadId)) {
                            case Some(abspth):
                                lookupFromAbs(abspth);
                            default:
                                trace("eventIntercepter/event/output Could not lookup path!");
                                trace(pth);
                                pth;
                        }
                        source.path = newPth;
                    }
                }
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

    function lookupFromAbs(abs:String) {
        final result = switch (fileTracker.lookupFile(abs)) {
            case SUPERIOR_FILE(superiorFile):
                trace("lookupFromAbs/ using superiror file");
                superiorFile;
            case CANT_FIND:
                trace("lookupFromAbs/ can't find calculated md5 succ");
                abs;
            case NOT_STORED:
                trace("lookupFromAbs/ none");
                final hshFunc = NodeCrypto.createHash("md5");
                final contents = Fs.readFileSync(abs,{encoding: 'utf8'});
                // trace(abs);
                // trace("-----------------");
                // trace(contents.toString());
                // trace("-----------------");
                hshFunc.update(contents.toString());
                fileTracker.storeLookupFile(abs,hshFunc.digest('hex'));
                null;
        }
        if (result != null) return result;
        return switch (fileTracker.lookupFile(abs)) {
            case SUPERIOR_FILE(superiorFile):
                trace("lookupFromAbs/ looked up calculated md5 lookup 2");
                superiorFile;
            case CANT_FIND:
                trace("lookupFromAbs/ can't find calculated md5 lookup 2");
                abs;
            case NOT_STORED:
                trace("lookupFromAbs/ something went bery wrong");
                throw "lookupFromAbs/ something went bery wrong";
                return null;
        }
    }

}

enum EventResult {
    NoSend;
    Send;
}
