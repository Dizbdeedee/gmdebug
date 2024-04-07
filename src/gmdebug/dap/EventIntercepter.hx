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
import gmdebug.dap.FileLookup;

using StringTools;

interface EventIntercepter {
	function event(ceptedEvent:Event<Dynamic>, threadId:Int):EventResult;
}

class EventIntercepterDef implements EventIntercepter {
	final luaDebug:LuaDebugger;

	final outputFilterer:OutputFilterer;

	final fileLookup:FileLookup;

	public function new(_luaDebug:LuaDebugger, _outputFilterer:OutputFilterer, _fileLookup:FileLookup) {
		luaDebug = _luaDebug;
		outputFilterer = _outputFilterer;
		fileLookup = _fileLookup;
	}

	public function event(ceptedEvent:Event<Dynamic>, threadId:Int):EventResult {
		return switch ((ceptedEvent.event : EventString<Dynamic>)) {
			case loadedSource:
				final loadedSourceEvent:LoadedSourceEvent = cast ceptedEvent;
				var source = loadedSourceEvent.body.source;
				return if (source == null) {
					trace("no source for loadedsource");
					NoSend;
				} else {
					final gmodPath:GmodPath = cast source.path;
					var gmodLocation:GmodLocationsNoLoc = switch (threadId) {
						case 0:
							SERVER;
						case x:
							CLIENT;
					}
					trace('*ncp looking up for $gmodLocation');
					var result = fileLookup.processGmodPath(gmodPath, gmodLocation);
					switch (result) {
						case EXISTS(CLIENT(abs), _) | EXISTS(SERVER(abs), _):
							source.path = abs;
							Send;
						case NONE if (gmodLocation == CLIENT):
							switch (fileLookup.processGmodPath(gmodPath, SERVER)) {
								case EXISTS(SERVER(abs2), _):
									trace('*ncp used backup server location for client');
									source.path = abs2;
									Send;
								default:
									trace('*ncp $gmodPath could not find backup on server ethier');
									NoSend;
							}
						case x:
							trace('*ncp $x Unable to load source for thread...');
							NoSend;
					}
				}
			case output:
				final outputEvent:OutputEvent = cast ceptedEvent;
				var source = outputEvent.body.source;
				if (source == null) {
					trace("No source for output");
				} else {
					var gmodPath:GmodPath = cast source.path;
					var allPaths = fileLookup.lookupAllLocations(gmodPath);
					var backup = "";
					var set = false;
					trace('*ncp output event! ' + allPaths);
					for (loc in allPaths) {
						switch (loc) {
							case PROJECT(str):
								trace("*ncp Found project path: " + str);
								source.path = str;
								set = true;
								break;
							case SERVER(str):
								backup = str;
							case CLIENT(str):
								backup = str;
							default:
						}
					}
					if (!set && backup != "") {
						trace("*ncp Found server path: " + backup);
						source.path = backup;
					}
				}
				Send;
			case stopped:
				final stoppedEvent:StoppedEvent = cast ceptedEvent;
				if (stoppedEvent.body.threadId != threadId) {
					stoppedEvent.body.threadId = threadId; // why does the client need to know it's id anyways??
					// TODO refactor this
				}
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
