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
		var ty = Gmod.type(val);
		var id:gmod.enums.TYPE = if (val != null) {
			Gmod.TypeID(val);
		} else {
			TYPE_NONE;
		}
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
		var generatedVariablesReference = generateVariablesReference(val,name);
		var obj:Variable = {
			name: name,
			type: ty,
			value: switch [ty, addv.props] {
				case ["table", NONE]:
					"table";
				case ["string", NONE]:
					'"$stringReplace"';
				case [_,NOQUOTE]:
					stringReplace;
				case [_, NOVALUE]:
					"";
				default:
					stringReplace;
			},
			variablesReference: generatedVariablesReference
		}
		switch [id, virtual] {
			case [TYPE_FUNCTION, false]:
				obj.presentationHint = {
					kind: Method,
					attributes: null,
					visibility: Public
				};
			case [_, false]:
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
		if (val == null) return 0;
		var cacheID = cachedValues.get(val);
		return switch [Gmod.TypeID(val),cacheID] {
			case [null,_]:
				0;
			case [TYPE_ENTITY,null] if (!Gmod.IsValid(val)):
				0;
			case [TYPE_TABLE | TYPE_FUNCTION | TYPE_USERDATA | TYPE_ENTITY,null]:
				cachedValues.set(val,storedVariables.length);
				VariableReference.encode(Child(debugee.clientID, storedVariables.push(val) - 1));
			case [TYPE_TABLE | TYPE_FUNCTION | TYPE_USERDATA | TYPE_ENTITY,cacheID]:
				trace("Where's my super cache");
				VariableReference.encode(Child(debugee.clientID, cacheID));
			default:
				0;
		};
	}

	
}

@:structInit
class AddVar {
	public var name:Dynamic;
	// std.string
	public var value:Dynamic;
	public var virtual:Null<Bool> = false;
	public var props:AddVarProperties = NONE;
}

enum AddVarProperties {
	NOQUOTE;
	NOVALUE;
	NONE;
}