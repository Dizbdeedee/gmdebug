package gmdebug.lua.debugcontext;

import haxe.macro.Expr;
import haxe.macro.Context;

class DebugContext {
    static var nextContextID = 1;

    public static macro function debugContext(funcCall:Expr) {
        var exprPos; 
        var blockExprs = switch (funcCall) {
            case {expr: EBlock(arr), pos: pos}:
                exprPos = pos;
                arr;
            case {pos: pos}:
                Context.error("DebugContext.debugContext needs a block expression", pos);
            default:
                Context.error("DebugContext.debugContext cannot process this",Context.currentPos());
        }
        var expectType = Context.getExpectedType();
        var modifiedBlockExprs;
        if (expectType != null) {
            modifiedBlockExprs = [macro gmdebug.lua.debugcontext.DebugContext.descendStack(),macro var result = $b{blockExprs}];
            modifiedBlockExprs.push(macro gmdebug.lua.debugcontext.DebugContext.ascendStack());
            modifiedBlockExprs.push(macro result);
        } else {
            modifiedBlockExprs = [macro gmdebug.lua.debugcontext.DebugContext.descendStack()].concat(blockExprs);
            modifiedBlockExprs.push(macro gmdebug.lua.debugcontext.DebugContext.ascendStack());
        }
        return {expr: EBlock(modifiedBlockExprs), pos: exprPos};
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

    public static macro function enterDebugContextSet(expr:Expr) {
        var contextID = nextContextID++;
        return macro {
            var mappedHeight = gmdebug.lua.debugcontext.DebugContext.mappedHeights[$v{contextID}];
            if (mappedHeight == null) {
                mappedHeight = gmdebug.lua.debugcontext.DebugContext.mapHeightNoCalc($v{contextID},$e{expr});
            }
            gmdebug.lua.debugcontext.DebugContext.resetHeight(mappedHeight);
        }
    }
}