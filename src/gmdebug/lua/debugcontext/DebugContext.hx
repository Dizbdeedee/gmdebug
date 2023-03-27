package gmdebug.lua.debugcontext;

import gmod.libs.DebugLib;

enum DebugContextState {
    NotDebug;
    InDebug;
}

class DebugContext {

    static var debugContextState:DebugContextState = NotDebug;

    //updated by descendstack
    static var currentLevel:Int = 0;

    //not updated by descendstack
    static var compareLevel:Int = 0;

    public static var mappedHeights = new gmod.helpers.LuaArray<Int>();

    /**
        Automatically added to all functions, used to manually check/crash for unmarked contexts.
        If we haven't run descendStack, we can detect it here, not in release mode
    **/
    public static inline function checkUnmarkedStack(?infos:haxe.PosInfos) {
        #if !release
        switch (debugContextState) {
            case NotDebug:
            case InDebug:
                if (currentLevel != compareLevel) {
                    //sneaky!
                    var _infos = infos;
                    _infos.fileName = _infos.className + "/" + _infos.methodName;
                    // haxe.Log.trace("MISSING STACK DESCENT HERE",_infos);
                    // haxe.Log.trace(DebugLib.traceback(),_infos);
                    currentLevel++;
                    compareLevel++;
                } else {
                    compareLevel++;
                }
        }
        #end
    }

    public static macro function debugContext(funcCall);

    public static macro function enterDebugContext();

    public static inline function descendStack() {
        currentLevel++;
        #if release
        compareLevel++;
        #end
    }

    public static inline function ascendStack() {
        currentLevel--;
        compareLevel--;
    }

    public static inline function exitDebug() {
        debugContextState = NotDebug;       
    }

    public static inline function getHeight() {
        if (debugContextState == NotDebug) trace("Attempt to get height not in debug context??");
        return currentLevel;
    }

    static var refMapHeight = mapHeight;

    public static inline function resetHeight(val:Int) {
        currentLevel = val;
        compareLevel = val + 1;
        debugContextState = InDebug;
    }

    public static function mapHeight(id:Int):Int {
        for (sh in 0...9999) {
            var info = DebugLib.getinfo((sh + 1), "f");
            if (info.func == refMapHeight) {
                mappedHeights[id] = sh - 1;
                trace('${sh - 1}');
                return sh - 1;
            } 
        }
        throw "MapHeight cannot find ourself?";
    }


    


}