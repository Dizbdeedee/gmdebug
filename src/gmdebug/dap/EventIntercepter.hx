package gmdebug.dap;

#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end

import gmdebug.composer.EventString;
import js.node.ChildProcess;
import vscode.debugAdapter.Protocol;
class EventIntercepter {
	public static function event(ceptedEvent:Event<Dynamic>, threadId:Int,luaDebug:LuaDebugger) {
		switch ((ceptedEvent.event : EventString<Dynamic>)) {
			case output:
				final outputEvent:OutputEvent = cast ceptedEvent;
				final prefix = if (threadId > 0) {
					'[C$threadId] - ';
				} else {
					"[S] - ";
				}
				outputEvent.body.output = prefix + outputEvent.body.output;
			case stopped:
				final stoppedEvent:StoppedEvent = cast ceptedEvent;
				if (luaDebug.initBundle.programs.xdotool && stoppedEvent.body.threadId > 0) {
					trace("free my mousepointer please!!");
					ChildProcess.execSync("setxkbmap -option grab:break_actions"); 
					ChildProcess.execSync("xdotool key XF86Ungrab");
				}
			default:
		}
	}
}
