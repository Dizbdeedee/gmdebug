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

    static var previousLevel:Int = 0;

    static var report = true;

    public static var mappedHeights = new gmod.helpers.LuaArray<Int>();

    public static inline function markReport() {
        report = true;
    }

    public static inline function markNotReport() {
        report = false;
    }

    /**
        Automatically added to all functions, used to manually check/crash for unmarked contexts.
        If we haven't run descendStack, we can detect it here, not in release mode
    **/
    public static inline function checkUnmarkedStack(?infos:haxe.PosInfos) {
        #if !release
        switch [debugContextState,report] {
            case [NotDebug,_]:
            case [InDebug,true]:
                if (currentLevel != compareLevel) {
                    //sneaky!
                    var _infos = infos;
                    if (report) {
                        _infos.fileName = _infos.className + "/" + _infos.methodName;
                        haxe.Log.trace("MISSING STACK DESCENT HERE",_infos);
                    }
                    
                    // haxe.Log.trace(DebugLib.traceback(),_infos);
                    // currentLevel++;
                    // compareLevel++;
                } else {
                    compareLevel++;
                }
            default:
        }
        #end
    }

    public static macro function debugContext(funcCall);

    public static macro function enterDebugContext();
    public static macro function enterDebugContextSet();


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

    public static inline function exitDebugContext() {
        currentLevel = previousLevel;
        debugContextState = NotDebug;       
    }

    public static inline function getHeight(?infos:haxe.PosInfos) {
        if (debugContextState == NotDebug) trace("Attempt to get height not in debug context??");
        // haxe.Log.trace('gotHeight $currentLevel',infos);
        // trace(mappedHeights);
        return currentLevel;
    }

    static var refMapHeight = mapHeight;

    public static inline function resetHeight(val:Int) {
        previousLevel = currentLevel;
        currentLevel = val;
        compareLevel = val + 1;
        debugContextState = InDebug;
    }

    public static function mapHeight(id:Int):Int {
        for (sh in 2...9999) {
            var info = DebugLib.getinfo(sh, "S");
            if (info == null) break;
            var compareSource = DebugLib.getinfo(1,"S").source;
            trace('${info.source} $compareSource');
            if (info.source == null || Util.isCSource(info.source)
                || info.source == compareSource) {
                continue;
            }
            mappedHeights[id] = sh;
            trace('Mapped height ${sh}');
            return sh;
            
        }
        throw "MapHeight cannot find ourself?";
    }
    public static function mapHeightNoCalc(id:Int,sh:Int):Int {
        mappedHeights[id] = sh;
        return sh;
    }


    


}