package gmdebug.lua.managers;

import gmod.helpers.WeakTools;
import gmdebug.lua.handlers.HScopes;
import gmod.gclass.Entity;
import gmod.libs.DebugLib;
import gmod.Gmod;
import lua.Lua;
import lua.NativeStringTools;
import gmdebug.VariableReference;
import gmdebug.lua.handlers.IHandler;
using gmod.helpers.WeakTools;
typedef InitVariableManager = {
	debugee : Debugee
}

class VariableManager {
    
	var storedVariables:Array<Null<Dynamic>> = [null];

	var cachedValues:haxe.ds.ObjectMap<Dynamic,Int> = new haxe.ds.ObjectMap();

	final debugee:Debugee;
	
	public function new(initVariableManager:InitVariableManager) {
		debugee = initVariableManager.debugee;
		storedVariables.setWeakValuesArr();
		cachedValues.setWeakKeysM();
	}

	public function resetVariables() {
		storedVariables = [null];
		storedVariables.setWeakValuesArr();
		cachedValues = new haxe.ds.ObjectMap();
		cachedValues.setWeakKeysM();
	}
    
    public function getVar(ind:Int) {
        return storedVariables[ind];
    }

	public function genvar(addv:AddVar):Variable {
		final name = Std.string(addv.name);
		final val = addv.value;
		var virtual = addv.virtual;
		var noquote = addv.noquote;
		var novalue = addv.novalue;
		var ty = Gmod.type(val);
		var id = Gmod.TypeID(val);
		var stringReplace = switch (ty) {
			case "table":
				"table";
			case "string":
				val;
			case "number":
				Std.string(val);
			default:
				Gmod.tostring(val);
		};
		var obj:Variable = {
			name: name,
			type: ty,
			value: switch [ty, noquote, novalue] {
				case ["table", _, _]:
					"table";
				case ["string", null, _]:
					'"$stringReplace"';
				case [_, _, true]:
					"";
				default:
					stringReplace;
			},
			variablesReference: generateVariablesReference(val,name)
		}
		switch [id, virtual] {
			case [TYPE_FUNCTION, null]:
				obj.presentationHint = {
					kind: Method,
					attributes: null,
					visibility: Public
				};
			case [_, null]:
			case [_, _]:
				obj.presentationHint = {
					kind: Virtual,
					attributes: null,
					visibility: Internal
				};
		}
		return obj;
	}

	public function generateVariablesReference(val:Dynamic, ?name:String):Int {
		var prevVarReference = cachedValues.get(val);
		if (prevVarReference == null && val != null) cachedValues.set(val,storedVariables.length);
		return switch [Gmod.TypeID(val),prevVarReference] {
			case [_,x] if (x != null):
				x;
			case [TYPE_ENTITY,null] if (!Gmod.IsValid(val)):
				0;
			case [TYPE_TABLE | TYPE_FUNCTION | TYPE_USERDATA | TYPE_ENTITY,null]:
				VariableReference.encode(Child(debugee.clientID, storedVariables.push(val) - 1));
			default:
				0;
		};
	}

	
}

typedef AddVar = {
	name:Dynamic,
	// std.string
	value:Dynamic,
	?virtual:Bool,
	?noquote:Bool,
	?novalue:Bool
}
