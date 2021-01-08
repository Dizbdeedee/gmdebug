package gmdebug.lua;

import gmdebug.lua.managers.FunctionBreakpointManager;
import gmdebug.lua.handlers.HEvaluate;
import gmdebug.composer.*;
import lua.Debug;
import haxe.Constraints.Function;
import lua.Lua;
import gmod.libs.DebugLib;
import gmod.Gmod;
import gmdebug.lua.managers.BreakpointManager;

using gmod.WeakTools;
using Safety;
using tink.CoreApi;

class DebugLoop {
	static var lineInfoFuncCache:haxe.ds.ObjectMap<Function, Bool> = new haxe.ds.ObjectMap();

	static var currentFunc:Null<haxe.Constraints.Function> = null;

	static var highestStackHeight:Float = Math.POSITIVE_INFINITY;

	static var escapeHatch:CatchOut = NONE;

	static var prevFunc:Null<Function> = null;

	static var prevStackHeight:Int = 0;

	static var bm:Null<BreakpointManager>;

	static var sc:Null<SourceContainer>;

	static var fbm:Null<FunctionBreakpointManager>;


	public static function init(bm:BreakpointManager,sc:SourceContainer) {
		DebugLoop.bm = bm;
		DebugLoop.sc = sc;
		DebugLoop.fbm = fbm;
	}

	inline static function nextCallStop(sinfo:SourceInfo, bp:Map<Int, Dynamic>) {
		var stop = false;
		for (k in bp.keys()) {
			if (k >= sinfo.linedefined && k <= sinfo.lastlinedefined) {
				stop = true;
				break;
			}
		}
		return stop;
	}

	public static extern inline function activateLineStepping() {
		Debug.sethook(debugloop, "cl");
	}

	static inline function shouldStopLine(curFunc:Function, sh:Int) {
		final stackHeight = (sh < highestStackHeight);
		final isEscape = switch (escapeHatch) {
			case OUT(outFunc) if (outFunc != curFunc):
				true;
			default:
				false;
		}
		return stackHeight || isEscape;
	}

	static function currentStackHeight(func:Function) {
		return if (func != prevFunc) {
			prevStackHeight = Debugee.stackHeight;
			prevStackHeight;
		} else {
			prevStackHeight;
		}
	}

	static extern inline function debug_switchHookState(cur:HookState, func:Function, ?sinfo:SourceInfo) {
		if (sinfo != null && highestStackHeight != null && escapeHatch != null) {
			if (cur == Call && bm.unsafe().breakpointWithinRange(sinfo.source, sinfo.linedefined,sinfo.lastlinedefined)) {
				final sh = currentStackHeight(func);
				if (sh < highestStackHeight) {
					Debug.sethook(debugloop, "cl");
					highestStackHeight = sh;
				}
			} else if (cur == Line && currentStackHeight(func) == Debugee.minheight && escapeHatch == NONE) {
				escapeHatch = OUT(func);
			} else if (cur == Line && shouldStopLine(func, currentStackHeight(func))) {
				escapeHatch = NONE;
				Debug.sethook(debugloop, "c");
				highestStackHeight = Math.POSITIVE_INFINITY;
			}
		}
	}

	static extern inline function debug_checkBreakpoints(sinfo:SourceInfo, line:Int) {
		switch (bm.getBreakpointForLine(sinfo.source,line)) {
			case null | {breakpointType : INACTIVE}:
			case {breakpointType : NORMAL}:
				trace("hit bp");
				Debugee.startHaltLoop(Breakpoint, Debugee.stackOffset.stepDebugLoop);
			case bp = {breakpointType : CONDITIONAL(condFunc)}:
				Gmod.setfenv(condFunc, HEvaluate.createEvalEnvironment(1));
				switch (Util.runCompiledFunction(condFunc)) {
					case Error(err):
						final message = HEvaluate.translateEvalError(err);
						final resp = new ComposedEvent(breakpoint, {
							reason: Changed,
							breakpoint: {
								id: bp.id,
								verified: false,
								message: 'Errored on run: $message'
							}
						});
						Lua.print('Conditional breakpoint in file ${sinfo.short_src}:${line} failed!');
						Lua.print('Error: $message');
						resp.send();
					case Success(val):
						if (val) {
							Debugee.startHaltLoop(Breakpoint, Debugee.stackOffset.stepDebugLoop);
						}
				}
		}
		
	}

	static extern inline function debug_step(cur:HookState, func:Function, ?curLine:Int):Bool {
		return switch Debugee.state {
			case null: // otherwise lua dump. not good
				false;
			case WAIT:
				false;
			case STEP(target) if (target == null || Debugee.stackHeight <= target):
				trace('stepped $target ${Debugee.stackHeight}');
				Debugee.state = WAIT;
				Debug.sethook(debugloop, "c");
				Debugee.startHaltLoop(Step, Debugee.stackOffset.stepDebugLoop);
				true;
			case STEP(x):
				true;
			case OUT(outFunc, lowest) if (outFunc == func && curLine.unsafe() == lowest):
				Debugee.state = WAIT;
				Lua.print(outFunc, func);
				Debug.sethook(debugloop, "c");
				Debugee.startHaltLoop(Step, Debugee.stackOffset.stepDebugLoop);
				true;
			case OUT(outFunc, _) if (outFunc != func):
				Debugee.state = WAIT;
				Lua.print(outFunc, func);
				Debug.sethook(debugloop, "c");
				Debugee.startHaltLoop(Step, Debugee.stackOffset.stepDebugLoop);
				true;
			case OUT(outFunc, _):
				Lua.print(outFunc, func, curLine);
				true;
			default:
				false;
		}
	}

	static extern inline function debug_functionalBP(func:Function, cur:HookState) {
		if (cur == Call) {
			currentFunc = null;
		}
		// TODO make function breakpoints update when target changes.
		// RUns on entry and exit
		if (func != null && fbm != null && currentFunc == null) {
			if (fbm.functionBP.exists(func)) {
				Debugee.startHaltLoop(FunctionBreakpoint, Debugee.stackOffset.stepDebugLoop);
			}
			currentFunc = func;
		}
	}

	// TODO if having inline breakpoints, only use instruction count when necessary (i.e when running the line to step through) also granuality ect.
	public static function debugloop(cur:HookState, currentLine:Int) {
		if (!Debugee.shouldDebug || Debugee.tracing)
			return;
		DebugLoopProfile.profile("getinfo", true);
		final func = DebugLib.getinfo(2, 'f').func; // activelines causes MASSIVE slowdown (6x)
		final result = sc.sourceCache.get(func);
		final sinfo = if (result != null) {
			result;
		} else {
			final tmp = DebugLib.getinfo(2, 'S');
			sc.sourceCache.set(func, tmp);
			tmp;
		}
		DebugLoopProfile.profile("step");
		final stepping = debug_step(cur, func, currentLine);
		DebugLoopProfile.profile("getbptable");
		if (Exceptions.exceptFuncs != null && func != null && Exceptions.exceptFuncs.exists(func))
			return;
		final bpValid = if (bm == null || !bm.valid())
				true;
			else
				false;
		DebugLoopProfile.profile("switchhookstate");
		if (!stepping && bpValid)
			debug_switchHookState(cur, func, sinfo);
		DebugLoopProfile.profile("checkBreakpoints");
		@:nullSafety(Off) if (cur == Line && bpValid)
			debug_checkBreakpoints(sinfo, currentLine);
		DebugLoopProfile.profile("functionalbp");
		debug_functionalBP(func, cur);
		DebugLoopProfile.resetprofile();
	}
}

private enum abstract HookState(String) {
	var Call = "call";
	var Line = "line";
	var _Return = "return";
}

typedef SourceInfo = {
	/**
		The line where the function definiton starts (where "function" is located).

		Option: S
	**/
	var linedefined:Int;

	/**
		The line the function definition ended (where "end" is located).

		Option: S
	**/
	var lastlinedefined:Int;

	/**
		The path to the file where the passed function is defined prepended by an @ (ex. "@lua/autorun/mytestfile.lua"). This will be the CompileString or RunString identifier if the function wasn't defined in a file, also prepended by an @.

		Option: S
	**/
	var source:String;

	/**
		The language used. Either "Lua" or "C".

		Option: S
	**/
	var what:gmod.structs.DebugInfo.What;

	/**
		The shortened name of the source (without the @). May be truncated if the source path is long.

		Option: S
	**/
	var short_src:String;
}

typedef FuncInfo = {
	/**
		Reference to the function that was passed in. If a stack level was specified, this will be the function at that stack level. 0 = debug.getinfo, 1 = function that called debug.getinfo, etc.

		Option: f
	**/
	var func:Function;
}

typedef SourceAndFuncInfo = FuncInfo & SourceInfo;

enum CatchOut {
	NONE;
	OUT(outFunc:Function);
}
