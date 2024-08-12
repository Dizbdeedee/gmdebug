package gmdebug.lua.debugee.managers;

import haxe.Constraints.Function;
import gmdebug.lua.debugee.handlers.IHandler;
import haxe.Constraints.Function;

class FunctionBreakpointManager {
	public final functionBP = new haxe.ds.ObjectMap<Function, Bool>();

	public function new() {}

	public function bpSet(x:Function) {
		return functionBP.exists(x);
	}
}
