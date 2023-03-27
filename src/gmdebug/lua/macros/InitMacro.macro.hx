package gmdebug.lua.macros;

import haxe.macro.Compiler;

class InitMacro {

    public static function addDebugContext() {
        Compiler.addGlobalMetadata("gmdebug","@:build(gmdebug.lua.macros.DebugContextMacro.build())");
    }
}