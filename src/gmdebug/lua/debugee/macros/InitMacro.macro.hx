package gmdebug.lua.debugee.macros;

import haxe.macro.Compiler;

class InitMacro {
	public static function addDebugContext() {
		Compiler.addGlobalMetadata("gmdebug", "@:build(gmdebug.lua.debugee.macros.DebugContextMacro.build())");
	}
}
