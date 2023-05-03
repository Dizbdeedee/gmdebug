package gmdebug.lua.handlers;


import gmod.helpers.LuaArray;
import gmdebug.lua.debugcontext.DebugContext;
import lua.Debug;
import gmod.enums.SENSORBONE;
import lua.NativeStringTools;
import gmod.libs.PlayerLib;
import gmod.libs.EntsLib;
import gmdebug.VariableReference;
import gmdebug.lua.managers.VariableManager;
import gmod.gclass.Entity;
import gmod.libs.DebugLib;

typedef InitHVariables = {
    debugee : Debugee,
    vm : VariableManager
}

class HVariables implements IHandler<VariablesRequest> {

    final variableManager:VariableManager;

    final debugee:Debugee;

    // var addVars:Array<AddVar> = [];

    public function new(initHVariables:InitHVariables) {
        debugee = initHVariables.debugee;
        variableManager = initHVariables.vm;
    }

    function realChild(storedvar:Dynamic,addVars:Array<AddVar>) {
        trace("Realy child!");
        switch Gmod.TypeID(storedvar) {
            case TYPE_TABLE:
                for (ind => val in (storedvar : AnyTable)) {
                    addVars.push({name: ind, value: val});
                }
            case TYPE_FUNCTION:
                var info = DebugLib.getinfo(storedvar, "S");
                addVars.push({
                    name: "(source)",
                    value: Gmod.tostring(info.short_src),
                    virtual: true,
                    props: NOQUOTE
                });
                addVars.push({name: "(line)", value: info.linedefined, virtual: true});
                final fenv = DebugLib.getfenv(storedvar);
                if (fenv != null) {
                    addVars.push({name : "(fenv)",value : fenv,virtual: true});
                }
                if (Debug.getupvalue(storedvar,1) != null) {
                    addVars.push({name : "(upvalues)",value : generateFakeChild(storedvar,Upvalues),virtual : true});
                }
            case TYPE_ENTITY:
                var ent:Entity = cast storedvar;
                // trace("bad?");
                var tbl = (storedvar : Entity).GetTable();
                addVars.push({name: "(position)", value: ent.GetPos(), virtual: true});
                addVars.push({name: "(angle)", value: ent.GetAngles(), virtual: true});
                addVars.push({name: "(model)", value: ent.GetModel(), virtual: true});
                for (ind => val in tbl) {
                    addVars.push({name: ind, value: val});
                }
            default:
        }
    }

    function fakeChild(realChild:Dynamic,type:FakeChild,addVars:Array<AddVar>) {
        switch (type) {
            case Upvalues:
                for (i in 1...9999) {
                    var upv = DebugLib.getupvalue(realChild, i);
                    if (upv.a == null)
                        break;
                    addVars.push({name: upv.a, value: upv.b});
                }
            case Output:
                addVars.push({name: "Bibbly bobbly boo", value: generateFakeChild(realChild,Output_Recurse),overrideValue: "Print Results: "});
            case Output_Recurse:
                for (k => v in (realChild : LuaArray<Dynamic>)) {
                    addVars.push({name : k, value: v});
                }

                // addVars.push({name: "Yikes!", value: "Cringe"});    
            // for (k => v in (realChild :lua.Table.AnyTable)) {
                //     addVars.push({name: k, value: v});
                // }
        }
    }

    function generateFakeChild(child:Dynamic,type:FakeChild) {
        final tab = Table.create();
        final meta = Table.create();
        final fakechild = Table.create();
        Lua.setmetatable(tab,meta);
        meta.__gmdebugFakeChild = fakechild;
        fakechild.child = child;
        fakechild.type = type;
        return tab;
    }

    function child(ref:Int,addVars:Array<AddVar>) {
        DebugContext.markNotReport();
        var storedvar:Dynamic = (variableManager.getVar(ref) : Any).unsafe();
        if (storedvar == null) {
            trace('Variable requested with nothing stored! $ref');
        }
        
        var mt = DebugLib.getmetatable(storedvar);
        if (mt != null) {
            if (mt.__gmdebugFakeChild != null) {
                var realChild = mt.__gmdebugFakeChild.child;
                var type = mt.__gmdebugFakeChild.type;
                fakeChild(realChild,type,addVars);
            } else {
                addVars.push({name: "(metatable)", value: mt,virtual : true});
                realChild(storedvar,addVars);
            }
        } else {
            realChild(storedvar,addVars);
        }
        DebugContext.markReport();
    }

    function frameLocal(offsetFrame:Int,scope:FrameLocalScope,addVars:Array<AddVar>) {
        final offsetHeight = DebugContext.getHeight();
        DebugContext.markNotReport();
        final realFrame = offsetFrame + offsetHeight;
        switch (scope) {
            case Arguments:
                var info = DebugLib.getinfo(realFrame, "u");
                for (i in 1...info.nparams + 1) {
                    var result = DebugLib.getlocal(realFrame, i);
                    if (result.a == null) {
                        break;
                    }
                    addVars.push({name: result.a, value: result.b});
                }
                for (i in 1...9999) {
                    var result = DebugLib.getlocal(realFrame, -i);
                    if (result.a == null)
                        break;
                    addVars.push({name: result.a, value: result.b});
                }
            case Locals:
                var info = DebugLib.getinfo(realFrame, "u");
                for (i in info.nparams + 1...9999) {
                    var result = DebugLib.getlocal(realFrame, i);
                    if (result.a == null) {
                        break;
                    }           
                    addVars.push({name: result.a, value: result.b});
                }
                // for (i in 1...9999) {
                //     var result = DebugLib.getlocal(realFrame, -i);
                //     if (result.a == null)
                //         break;
                //     addVars.push({name: result.a, value: result.b});
                // }
            case Upvalues:
                var info = DebugLib.getinfo(realFrame, "f");
                if (info != null && info.func != null) {
                    for (i in 1...9999) {
                        var func = (info.func : Dynamic); // otherwise _hx_bind..?
                        var upv = DebugLib.getupvalue(func, i);
                        if (upv.a == null)
                            break;
                        addVars.push({name: upv.a, value: upv.b});
                    }
                }
            case Fenv:
                var info = DebugLib.getinfo(realFrame, "f");
                if (info != null && info.func != null) {
                    final func = (info.func : Dynamic);
                    final tbl = DebugLib.getfenv(func);
                    for (i => p in tbl) {
                        addVars.push({name: i, value: p});
                    }
                }
        }
        DebugContext.markReport();
    }

    function global(scope:ScopeConsts,addVars:Array<AddVar>) {
        DebugContext.markNotReport();
        switch (scope) {
            case Globals:
                var _g:AnyTable = untyped __lua__("_G");
                var sort:Array<String> = [];
                addVars.push({name: "_G", value: ""});
                for (i => x in _g) {
                    if (Lua.type(i) == "string") {
                        if (isEnum(i, x)) {
                        } else {
                            sort.push(i);
                        }
                    }
                }
                for (index in sort) {
                    if (Lua.type(index) == "string") {
                        addVars.push({name: index, value: _g[untyped index]});
                    }
                }
            case Enums:
                var _g:AnyTable = untyped __lua__("_G");
                for (i => x in _g) {
                    if (Lua.type(i) == "string") {
                        if (isEnum(i, x)) {
                            addVars.push({name: i, value: x});
                        } 
                    }
                }
            case Players:
                for (i => ply in PlayerLib.GetAll()) {
                    addVars.push({name: ply.GetName(), value: ply});
                }
            case Entities:
                final ents = EntsLib.GetAll();
                for (i in 1...EntsLib.GetCount()) {
                    var ent = ents[i];
                    addVars.push({name: ent.GetClass(), value: ent});
                }
            default:
                trace("Unhandled global scope");
        }
        DebugContext.markReport();
    }

    function isEnum(index:String, value:Dynamic) {
		return NativeStringTools.match(index, "%u", 1) != null
			&& NativeStringTools.match(index, "%u", 2) != null
			&& Lua.type(value) == "number";
    }

    function fixupNames(variables:Array<Variable>) {
        final varnamecount:Map<String, Int> = [];
        for (v in variables) {
            if (v.name == null) continue;
            final count = varnamecount.get(v.name);
            if (count != null) {
                varnamecount.set(v.name, count + 1);
                v.name = '${v.name} ($count)';
            } else {
                varnamecount.set(v.name, 1);
            }
        }
    }

    public function handle(req:VariablesRequest) {
		final args = req.arguments.unsafe();
		final ref:VariableReference = args.variablesReference;
        trace(ref);
        final addVars:Array<AddVar> = [];
		DebugContext.debugContext({
            switch (ref.getValue()) {
                case Child(_, ref):
                    child(ref,addVars);
                case FrameLocal(_, frame, scope):
                    frameLocal(frame,scope,addVars);
                case Global(_, scope):
                    global(scope,addVars);
                case INVALID:
                    trace("INVALID");
                    [];
	    	}
        });
        DebugContext.markNotReport();
        var variablesArr = [];
        for (addV in addVars) {
            variablesArr.push(variableManager.genvar(addV));
        }
		fixupNames(variablesArr);
		var resp = req.compose(variables, {variables: variablesArr});
		final js = tink.Json.stringify((cast resp : VariablesResponse)); 
		debugee.send(js);
        DebugContext.markReport();
		return WAIT;
	}
}
