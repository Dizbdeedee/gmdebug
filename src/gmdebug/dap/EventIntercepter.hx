package gmdebug.dap;

import gmdebug.Cross.OUTPUT_INTERCEPTED;
#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end

import gmdebug.composer.EventString;
import js.node.ChildProcess;
using StringTools;

interface EventIntercepter {
	function event(ceptedEvent:Event<Dynamic>, threadId:Int):EventResult;
}


class EventIntercepterDef implements EventIntercepter {

	final luaDebug:LuaDebugger;

	public function new(_luaDebug:LuaDebugger) {
		luaDebug = _luaDebug;
	}

	public function event(ceptedEvent:Event<Dynamic>, threadId:Int):EventResult {
		return switch ((ceptedEvent.event : EventString<Dynamic>)) {
			case output:
				final outputEvent:OutputEvent = cast ceptedEvent;
				final prefix = if (threadId > 0) {
					'[C$threadId] - ';
				} else {
					"[S] - ";
				}
				outputEvent.body.output = prefix + outputEvent.body.output;
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
