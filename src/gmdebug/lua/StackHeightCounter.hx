package gmdebug.lua;

#if macro
import haxe.macro.Expr;
#end

#if lua
import gmod.libs.DebugLib;
#end

class StackHeightCounter {

    #if !macro
    static var shOffset:Int = 1;

    public static extern inline function increment() {
        shOffset++;
    }

    public static extern inline function decrement() {
        shOffset--;
    }
    
    public static extern inline function entry() {
        shOffset = 1;    
    }

    static extern inline function getSH() {
        var i = 1;
        while (i < 99999) {
            var info = DebugLib.getinfo(i,"");
            if (info == null) break;
            i++;
        }
        return i - 1;
    }

    /**
        Real Stack Start
    **/
    public static extern inline function getRSS() {
        return shOffset + 1;
    }

    /**
        Real Stack Height
    **/
    public static extern inline function getRSH() {
        return getSH() - shOffset;
    }

    public static extern inline function getSHOffset() {
        return shOffset;
    }
    #end

    public static macro function wrap(expr:Expr) {
        return macro {
            gmdebug.lua.StackHeightCounter.increment();
            $e{expr}
            gmdebug.lua.StackHeightCounter.decrement();
        }
    }

   
    
}