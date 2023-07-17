package gmdebug.lua;

import gmdebug.Util.embedResource;
import haxe.Resource;
import gmod.libs.EffectsLib;
import tink.core.Signal;
import gmod.stringtypes.Hook.GMHook;
#if client
import gmod.libs.VguiLib;
#end
import gmod.libs.TimerLib;
import gmod.libs.GamemodeLib;
import gmod.libs.HookLib;
import haxe.Rest;
import gmod.libs.Scripted_entsLib;
import haxe.Constraints.Function;
import haxe.ds.ObjectMap;
using gmod.helpers.WeakTools;

typedef ReplaceStorage = {
    ?scripted_ents_lib_register : Function,
    ?hooklib_add : Function,
    ?gamemodelib_register : Function,
    ?timerlib_create : Function,
    ?timerlib_simple : Function,
    ?vguilib_register : Function,
    ?effectslib_register : Function
}

typedef TracebackFunction = (err:Dynamic) -> Dynamic;

class Exceptions {

    final exceptFuncs:ObjectMap<Dynamic,Dynamic> = new ObjectMap();

    final replaceStorage:ReplaceStorage = {};

    final tracebackFunc:TracebackFunction;

    var xpCallActive = false;

    public function new(_tracebackFunc:TracebackFunction) {
        tracebackFunc = _tracebackFunc;
        exceptFuncs.setWeakKeyValuesM();
        WeakTools.setGCMethod(cast this,__gc);
    }

    public function hooks() {
        hookGamemode();
        hookEntities();
        hookHooks();
        // hookEffects();
        // hookPanels();
        hookTimers();
    }

    public function addExcept(target:Function):Dynamic {
        final traceback:(err:String) -> Void = (err) -> tracebackFunc(err);
        final exceptSelf = this;
        var catchError = untyped __lua__(embedResource("Catch"),exceptSelf);
        var xpCall = untyped __lua__(embedResource("XPCall"),target,traceback,catchError,exceptSelf);
        exceptFuncs.set(traceback,target);
        exceptFuncs.set(catchError,target);
        exceptFuncs.set(xpCall,target);
        return xpCall;
    }

    function processExcept(func:Function):Function {
        return if (shouldExcept(func)) {
            addExcept(func);
        } else {
            func;
        }
    }

    public function isExcepted(f:Function):Bool {
        return exceptFuncs.exists(f);
    }

    function shouldExcept(x:Dynamic) {
        return Lua.type(x) == "function" && !isExcepted(x);
    }

    function shouldUnexcept(x:Dynamic) {
        return Lua.type(x) == "function" && isExcepted(x);
    }

    function getOldFunc(hook:Function) {
        return exceptFuncs.get(hook);
    }

    function __gc() {
        trace("gc ran");
    }

    function processUnExcept(func:Function):Function {
        return if (shouldUnexcept(func)) {
            final oldFunc = getOldFunc(func);
            exceptFuncs.remove(func);
            oldFunc;
        } else {
            func;
        }
    }

    function hookHooks() {
        for (hookname => hook in HookLib.GetTable()) {
            for (ident => hooks in hook) {
                if (shouldExcept(hooks)) {
                    HookLib.Add(hookname,ident, addExcept(hooks));
                }
            }
        }
        replaceStorage.hooklib_add = HookLib.Add;
        untyped HookLib.Add = (name,ident,func,rest:Rest<Any>) -> {
            replaceStorage.hooklib_add(name,ident,processExcept(func),rest);
        };
    }

    function hookGamemode() {
        if (Gmod.GAMEMODE != null) { //what
            for (ind => gm in Gmod.GAMEMODE) {
                Gmod.GAMEMODE[ind] = processExcept(gm);
            }
        }
        replaceStorage.gamemodelib_register = GamemodeLib.Register;
        untyped GamemodeLib.Register = (gm, name, derived) -> {
            for (ind => val in gm) {
                gm[ind] = processExcept(val);
            }
            replaceStorage.gamemodelib_register(gm,name,derived);
        }
    }

    function hookSweps() {
        HookLib.Add("PreRegisterSWEP","gmdebug_present",(swep:AnyTable,strClass) -> {
            for (ind => val in swep) {
                swep[ind] = processExcept(val);
            }
        }); //TODO, gmodhaxe ect.
    }

    //change to use PreRegisterSent hook
    function hookEntities() {
        for (entName in Scripted_entsLib.GetList().keys()) {
            final entTbl = Scripted_entsLib.GetStored(entName);
            for (ind => val in entTbl.t) {
                entTbl.t[ind] = processExcept(val);
            }
        }
        replaceStorage.scripted_ents_lib_register = Scripted_entsLib.Register;
        untyped Scripted_entsLib.Register = (ENT,name) -> {
            for (ind => val in ENT) {
                ENT[ind] = processExcept(val);
            }
            replaceStorage.scripted_ents_lib_register(ENT,name);
        }
    }

    function hookTimers() {
        replaceStorage.timerlib_create = TimerLib.Create;
        replaceStorage.timerlib_simple = TimerLib.Simple;
        untyped TimerLib.Create = (ident, delay, rept, func) -> {
            replaceStorage.timerlib_create(ident,delay,rept,processExcept(func));
        }
        untyped TimerLib.Simple = (delay, func) -> {
            replaceStorage.timerlib_simple(delay,processExcept(func));
        }
    }

    function hookPanels() {
        #if client
        replaceStorage.vguilib_register = VguiLib.Register;
        untyped VguiLib.Register = (name,mtable,base) -> {
            for (ind => val in mtable) {
                mtable[ind] = processExcept(val);
            }
            replaceStorage.vguilib_register(name,mtable,base);
            trace('register $name');
        }
        #end
    }



    function hookEffects() {
        #if client
        replaceStorage.effectslib_register = EffectsLib.Register;
        untyped EffectsLib.Register = (table,name) -> {
            for (ind => val in table) {
                table[ind] = processExcept(val);
            }
            replaceStorage.effectslib_register(table,name);
        }
        #end
    }

    function unHookhooks() {
        for (hookname => hook in HookLib.GetTable()) {
            for (ident => hooks in hook) {
                HookLib.Add(hookname,ident,processUnExcept(hooks));
            }
        }
        if (replaceStorage.hooklib_add != null) {
            untyped HookLib.Add = replaceStorage.hooklib_add;
        }

    }

    function unhookGamemode() {
        if (Gmod.GAMEMODE != null) { //what
            for (ind => gm in Gmod.GAMEMODE) {
                Gmod.GAMEMODE[ind] = processExcept(gm);
            }
        }
        if (replaceStorage.gamemodelib_register != null) {
            untyped GamemodeLib.Register = replaceStorage.gamemodelib_register;
        }
    }

    function unhookEntities() {
        if (replaceStorage.scripted_ents_lib_register != null) {
            untyped Scripted_entsLib.Register = replaceStorage.scripted_ents_lib_register;
        }
        for (entName in Scripted_entsLib.GetList().keys()) {
            final entTbl = Scripted_entsLib.GetStored(entName);
            for (ind => val in entTbl.t) {
                entTbl.t[ind] = processUnExcept(val);
            }
        }
    }

    function unhookSweps() {
        HookLib.Remove("PreRegisterSWEP","gmdebug_present");

    }

    //can't unhook already hooked timers. problems ahoy
    //keep track of names, i guess. timer is c sided
    function unhookTimers() {
        if (replaceStorage.timerlib_create != null) {
            untyped TimerLib.Create = replaceStorage.timerlib_create;
        }
        if (replaceStorage.timerlib_simple != null) {
            untyped TimerLib.Simple = replaceStorage.timerlib_simple;
        }
    }

    //missing runtime unhook
    function unhookPanels() {
        #if client
        if (replaceStorage.vguilib_register != null) {
            untyped VguiLib.Register = replaceStorage.vguilib_register;
        }
        #end
    }

    //missing runtime unhook
    function unhookEffects() {
        #if client
        if (replaceStorage.effectslib_register != null) {
            untyped EffectsLib.Register = replaceStorage.effectslib_register;
        }
        #end
    }
}
