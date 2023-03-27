package gmdebug.lua.debugcontext;

import haxe.macro.Expr;

class DebugContext {
    static var nextContextID = 1;

    public static macro function debugContext(funcCall:Expr) {
        return macro {
            gmdebug.lua.debugcontext.DebugContext.descendStack();
            $e{funcCall}
            gmdebug.lua.debugcontext.DebugContext.ascendStack();
        }
    }

    public static macro function enterDebugContext() {
        var contextID = nextContextID++;
        return macro {
            var mappedHeight = gmdebug.lua.debugcontext.DebugContext.mappedHeights[$v{contextID}];
            if (mappedHeight == null) {
                mappedHeight = gmdebug.lua.debugcontext.DebugContext.mapHeight($v{contextID});
            }
            gmdebug.lua.debugcontext.DebugContext.resetHeight(mappedHeight);
        }
        
    }
}