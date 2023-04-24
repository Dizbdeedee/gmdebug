package gmdebug.lua.handlers;

import gmdebug.lua.debugcontext.DebugContext;
import gmod.libs.DebugLib;
import gmdebug.composer.ComposedEvent;
using StringTools;


typedef InitHStackTrace = {
	debugee : Debugee,
	exceptions : Exceptions
}

class HStackTrace implements IHandler<StackTraceRequest> {

	final debugee:Debugee;

	final exceptions:Exceptions;

	public function new(init:InitHStackTrace) {
		debugee = init.debugee;
		exceptions = init.exceptions;
	}

	public function handle(x:StackTraceRequest):HandlerResponse {
		DebugContext.markNotReport();
		final sh = debugee.stackHeight;
		final offsetHeight = DebugContext.getHeight();
		final args = x.arguments.unsafe();
		if (!debugee.pauseLoopActive) {
			var response = x.compose(stackTrace, {
				stackFrames: [],
				totalFrames: 0
			});
			final jsonStackTraceResp = tink.Json.stringify((cast response : StackTraceResponse)); // in pratical terms they're the same
			debugee.send(jsonStackTraceResp);
			debugee.sendMessage(new ComposedEvent(continued, {
				threadId: debugee.clientID,
				allThreadsContinued: false
			}));
			return WAIT;
		}
		final len = DebugLoop.debug_stack_len() - offsetHeight;
		final firstFrame = switch (args.startFrame) {
			case null:
				offsetHeight;
			case x:
				x + offsetHeight;
		}
		trace('FIRSTFRAME $firstFrame');
		
		final lastFrame = switch (args.levels) {
			case null | 0:
				9999;
			case x:
				firstFrame + x;
		}
		final stackFrames:Array<StackFrame> = [];
		for (i in firstFrame...lastFrame) {
			var info = DebugLib.getinfo(i, "lnSfu");
			if (info == null)
				break;
			var src = switch (info.source.charAt(0)) {
				case "@":
					@:nullSafety(Off) info.source.substr(1);
				default:
					info.source;
			}
			var args:String = "";
			if (info.nparams > 0) {
				args = "(";
				for (p in 0...info.nparams) {
					final lcl = DebugLib.getlocal(i, p);
					final val = switch (Lua.type(lcl.b)) {
						case "table":
							"table";
						case "string":
							'"${lcl.b}"';
						default:
							Gmod.tostring(lcl.b);
					}
					args += '${lcl.a}=$val,'; // ${Lua.type(lcl.b)}
				}
				// vargs
				for (p in 1...9999) {
					final lcl = DebugLib.getlocal(i, -p);
					if (lcl.a == null)
						break;
					final val = switch (Lua.type(lcl.b)) {
						case "table":
							"table";
						case "string":
							'"${lcl.b}"';
						default:
							Gmod.tostring(lcl.b);
					}
					args += '${lcl.a}=$val,';
				}
				args = args.substr(0, args.length - 1) + ")";
			}
			var name = switch [info.name, info.namewhat] {
				case [null, NOT_FOUND]:
					'${sh - i} | anonymous function $args';
				// case [null,what]:
				//     'anonymous function ';
				case [name, what]:
					'${sh - i} | [$what] $name $args';
			}
			var path:Null<String>;
			var hint:Null<SourcePresentationHint>;
			var line;
			var column;
			var endLine:Null<Int> = null;
			var endColumn:Null<Int> = null;
			switch [Util.isCSource(src),src,len] {
				case [true,_,_]:
					hint = Deemphasize;
					path = null;
					line = 0;
					column = 0;
				case [false,src,len] if ((len > 80 && i > 45 && (i - 5) < len - 40)):
					path = debugee.normalPath(src);
					hint = Deemphasize;
					line = info.currentline;
					column = 1;
					endLine = info.lastlinedefined;
					endColumn = 99999;
				case [false,src,_]:
					path = debugee.normalPath(src);
					hint = null;
					line = info.currentline;
					column = 1;
					endLine = info.lastlinedefined;
					endColumn = 99999;
			}
			hint = Normal;
			if (info.func != null && exceptions.isExcepted(info.func)) {
				line = 0;
				path = null;
				column = 0;
				hint = Deemphasize;
				name = "Exception catcher";
			} else {
				hint = Normal;
			}
			var target:StackFrame = {
				id: gmdebug.FrameID.encode(debugee.clientID.sure(), i - offsetHeight),
				name: name,
				source: switch path {
					case null:
						null;
					case path:
						var pth = @:nullSafety(Off) path.split("/");
						{
							name: pth[pth.length - 1],
							path: path,
							presentationHint: hint
						};
				},
				line: line,
				column: column,
				endLine: endLine,
				endColumn: endColumn,
				// presentationHint:
			}
			if (path != null) {
				target.source.unsafe().path = path;
			}
			stackFrames.push(target);
		}
		var response = x.compose(stackTrace, {
			stackFrames: stackFrames,
			totalFrames: len
		});
		final json = tink.Json.stringify((cast response : StackTraceResponse)); // in pratical terms they're the same
		debugee.send(json);
		DebugContext.markReport();
		return WAIT;
	}
}
