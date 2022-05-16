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

@:multiReturn
private extern class Dur {
    var a:Int;
    var b:Int;
    var c:Int;
    var d:Int;
    var e:Int;
    var f:Int;
    var g:Int;
    var h:Int;
    var i:Int;
    var j:Int;
    var k:Int;
}

class Exceptions {

    final exceptFuncs:ObjectMap<Dynamic,Dynamic> = new ObjectMap();

    final debugee:Debugee;

    final replaceStorage:ReplaceStorage = {};

    var xpCallActive = false;

    public function new(_debugee:Debugee) {
        debugee = _debugee;
        exceptFuncs.setWeakKeyValuesM();
        WeakTools.setGCMethod(cast this,__gc);
    }

    public function hooks() {
        var countReturns:(_:Dynamic) -> Dur = untyped __lua__(embedResource("CountReturns"));
        final testFunc = untyped __lua__("function (a,b,c,d,e,f,g,h,i,j,k) return a,b end");
        final excepted = addExcept(testFunc);
        final r = countReturns(excepted(1,2,3,4,5,6,7,8,9,10,11));
        // trace(r);
        trace('${r.a} ${r.b} ${r.c} ${r.d} ${r.e} ${r.f} ${r.g} ${r.h} ${r.i} ${r.j} ${r.k}');
        hookGamemode();
        hookEntities();
        hookHooks();
        hookEffects();
        hookPanels();
        hookTimers();
    }

    function addExcept(target:Function) {
        final meth:(err:String) -> Void = cast debugee.traceback;
        var exceptedFunc = untyped __lua__("function (...) local success,vrtn,vrtn2,vrtn3,vrtn4,vrtn5,vrtn6,vrtn7,vrtn8,vrtn9,vrtn10,vrtn11,vrtn12 = xpcall({0},{1},...) if success then return vrtn,vrtn2,vrtn3,vrtn4,vrtn5,vrtn6,vrtn7,vrtn8,vrtn9,vrtn10,vrtn11,vrtn12 else print(\"Error attempting to traceback! Could not debug!!\") error(vargs,99) end end",
			target,
			meth); //unpacking into a table could cause perfomance concerns... maybe
        exceptFuncs.set(meth,target);
        exceptFuncs.set(exceptedFunc,target);
        return exceptedFunc;
    }

    function testExcept(name:String,index:String,target:Function) {
        if (index == "GetLeftMin") return target;
        final meth:(err:String) -> Void = cast debugee.traceback;
        final selfself = this;
        var countReturns = untyped __lua__(embedResource("CountReturns"));
        var exceptedFunc = untyped __lua__(embedResource("TestExcept"),
            target,
            meth,
            countReturns,
            selfself
            );
            // name,index);//
        exceptFuncs.set(meth,target);
        exceptFuncs.set(exceptedFunc,target);
        return exceptedFunc;
    }
    
    function testExcept2(name:String,index:String,target:Function) {
        final traceback:(err:String) -> Void = cast debugee.traceback;
        final selfself = this;
        final Xphandle = untyped __lua__(embedResource("Xphandle"));
        final exceptedFunc = untyped __lua__(embedResouce("TestExcept2"),
            target,
            meth,
            Xphandle,
            selfself
        );
        exceptFuncs.set(traceback,target);
        exceptFuncs.set(exceptedFunc,target);
    }

    function processTestExcept(name:String,index:String,func:Function) {
        return if (shouldExcept(func)) {
            testExcept(name,index,func);
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

    function processExcept(func:Function):Function {
        return if (shouldExcept(func)) {
            addExcept(func);
        } else {
            func;
        }
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
                mtable[ind] = processTestExcept(name,cast ind,val);
            }
            replaceStorage.vguilib_register(name,mtable,base);
            // trace('register $name');
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