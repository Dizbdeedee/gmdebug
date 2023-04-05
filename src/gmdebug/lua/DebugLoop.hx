package gmdebug.lua;

import gmod.libs.JitLib;
import gmdebug.lua.managers.FunctionBreakpointManager;
import gmdebug.lua.handlers.HEvaluate;
import gmdebug.composer.*;
import lua.Debug;
import haxe.Constraints.Function;
import lua.Lua;
import gmod.libs.DebugLib;
import gmod.Gmod;
import gmdebug.lua.managers.BreakpointManager;

using gmod.helpers.WeakTools;
using Safety;
using tink.CoreApi;
using gmdebug.lua.GmodPath;

typedef InitDebugLoop = {
	bm : BreakpointManager,
	sc : SourceContainer,
	fbm : FunctionBreakpointManager,
	debugee : Debugee,
	exceptions : Exceptions
}

class DebugLoop {

	static var lineInfoFuncCache:haxe.ds.ObjectMap<Function, Bool> = new haxe.ds.ObjectMap();

	static var currentFunc:Null<haxe.Constraints.Function> = null;

	static var highestStackHeight:Float = Math.POSITIVE_INFINITY;

	static var escapeHatch:CatchOut = NONE;

	static var prevFunc:Null<Function> = null;

	static var prevStackHeight:Int = 0;

	static var debugStopExecution = 10;

	static var debugCheckRun = 0;

	static var debugCheckRuns = 10000;

	//dee dee diane
	static var lineSteppin:Bool = false;

	static var supressCheckStack:Option<Int> = None;

	static var bm:Null<BreakpointManager>;

	static var sc:Null<SourceContainer>;

	static var exceptions:Null<Exceptions>;

	static var debugee:Debugee;

	static var fbm:Null<FunctionBreakpointManager>;

	public static function init(initDebugLoop:InitDebugLoop) {
		bm = initDebugLoop.bm;
		sc = initDebugLoop.sc;
		debugee = initDebugLoop.debugee;
		fbm = initDebugLoop.fbm;
		exceptions = initDebugLoop.exceptions;
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

	public static extern inline function enableLineStep() {
		DebugHook.addHook(debugloop, "cl");
		lineSteppin = true;
	}

	public static extern inline function disableLineStep() {
		DebugHook.addHook(debugloop,"c");
		lineSteppin = false;
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

	static inline extern function currentStackHeight(func:Function) {
		return if (func != prevFunc) {
			prevStackHeight = StackHeightCounter.getRSH();
			prevStackHeight;
		} else {
			prevStackHeight;
		}
	}

	static extern inline function debug_switchHookState(cur:HookState, func:Function, ?sinfo:SourceInfo) {
		if (sinfo != null && highestStackHeight != null && escapeHatch != null) {
			if (!lineSteppin && bm.unsafe().breakpointWithinRange(sinfo.source.gPath(), sinfo.linedefined, sinfo.lastlinedefined)) {
				final sh = currentStackHeight(func);
				if (sh <= highestStackHeight) {
					enableLineStep();
					highestStackHeight = sh;
				}
			} else if (cur == Line && currentStackHeight(func) < 1 && escapeHatch == NONE) {
				escapeHatch = OUT(func);
			} else if (cur == Line && shouldStopLine(func, currentStackHeight(func))) {
				escapeHatch = NONE;
				disableLineStep();
				highestStackHeight = Math.POSITIVE_INFINITY;
			}
		}
	}


	static extern inline function debug_checkBreakpoints(sinfo:SourceInfo, line:Int) {
		switch (bm.getBreakpointForLine(sinfo.source.gPath(),line)) {
			case null | {breakpointType : INACTIVE}:
			case {breakpointType : NORMAL}:
				StackHeightCounter.wrap(debugee.startHaltLoop(Breakpoint));
			case {breakpointType : CONDITIONAL(condFunc), id : bpID}:
				Gmod.setfenv(condFunc, HEvaluate.createEvalEnvironment(3 + DebugHook.HOOK_USED));
				switch (Util.runCompiledFunction(condFunc)) {
					case Error(err):
						final message = HEvaluate.translateEvalError(err);
						final resp = new ComposedEvent(breakpoint, {
							reason: Changed,
							breakpoint: {
								id: bpID,
								verified: false,
								message: 'Errored on run: $message'
							}
						});
						Lua.print('Conditional breakpoint in file ${sinfo.short_src}:${line} failed!');
						Lua.print('Error: $message');
						debugee.sendMessage(resp);
					case Success(val):
						if (val) {
							StackHeightCounter.wrap(debugee.startHaltLoop(Breakpoint));
						}
				}
		}
		
	}

	static extern inline function debug_step(cur:HookState, func:Function, ?curLine:Int):Bool {
		return switch debugee.state {
			case null: // otherwise lua dump. not good
				false;
			case WAIT:
				false;
			case STEP(target) if (target == null || StackHeightCounter.getRSH() <= target):
				debugee.state = WAIT;
				disableLineStep();
				StackHeightCounter.wrap(debugee.startHaltLoop(Step));
				true;
			case STEP(x):
				true;
			case OUT(outFunc, lowest,_) if (outFunc == func && curLine.unsafe() == lowest):
				debugee.state = WAIT;
				Lua.print(outFunc, func);
				disableLineStep();
				StackHeightCounter.wrap(debugee.startHaltLoop(Step));
				true;
			case OUT(outFunc, _,tarHeight) if (outFunc != func && StackHeightCounter.getRSH() <= tarHeight):
				debugee.state = WAIT;
				Lua.print(outFunc, func);
				disableLineStep();
				StackHeightCounter.wrap(debugee.startHaltLoop(Step));
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
				StackHeightCounter.wrap(debugee.startHaltLoop(FunctionBreakpoint));
			}
			currentFunc = func;
		}
	}

	static extern inline function debug_debugLoop() {
		// #if debug
		debugCheckRun++;
		if (debugCheckRun > debugCheckRuns) {
			debugCheckRun = 0;
			final curTime = Gmod.SysTime();
			if (curTime > debugStopExecution && debugStopExecution > 0) {
				debugStopExecution = -1;
				StackHeightCounter.wrap(debugee.startHaltLoop(Breakpoint));
			}
		}
		// #end
	}

	// TODO if having inline breakpoints, only use instruction count when necessary (i.e when running the line to step through) also granuality ect.
	public static function debugloop(cur:HookState, currentLine:Int) {
		StackHeightCounter.entry();
		debug_debugLoop();
		if (debugee.pollActive || debugee.tracebackActive)
			return;
		DebugLoopProfile.profile("getinfo", true);
		final func = DebugLib.getinfo(StackHeightCounter.getRSS(), 'f').func;
		final result = sc.sourceCache.get(func);
		final sinfo = if (result != null) {
			result;
		} else {
			final tmp = DebugLib.getinfo(StackHeightCounter.getRSS(), 'S');
			sc.sourceCache.set(func, tmp);
			tmp;
		}
		DebugLoopProfile.profile("step");
		@:privateAccess if (exceptions.exceptFuncs != null && func != null && exceptions.exceptFuncs.exists(func))
			return;
		final stepping = debug_step(cur, func, currentLine);
		DebugLoopProfile.profile("getbptable");
		final bpValid = if (bm != null && bm.valid())
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
