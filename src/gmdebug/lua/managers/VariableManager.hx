package gmdebug.lua.managers;

import gmod.libs.HookLib;
import gmdebug.WordList.WORD_ARRAY;
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
using Lambda;

typedef InitVariableManager = {
	debugee:Debugee
}

typedef WordsStorageType = {
	table:WordsStorage,
	funcs:WordsStorage
}

@:structInit
class WordsStorage {
	public final wordsAvaliable:Array<String> = WORD_ARRAY.array();
	public final toName:haxe.ds.ObjectMap<Dynamic, String> = _createToName();

	static function _createToName() {
		var toName = new haxe.ds.ObjectMap();
		toName.setWeakKeysM();
		return toName;
	}
}

class VariableManager {
	var storedVariables:Array<Null<Dynamic>> = [null];

	var cachedValues:haxe.ds.ObjectMap<Dynamic, Int> = new haxe.ds.ObjectMap();

	final wordsStorageType:WordsStorageType = {
		table: {},
		funcs: {}
	}

	var caniocalNames:haxe.ds.ObjectMap<Dynamic, UniqueName> = new haxe.ds.ObjectMap();

	var traverseDepth:Int = 2;

	final debugee:Debugee;

	public function new(initVariableManager:InitVariableManager) {
		debugee = initVariableManager.debugee;
		storedVariables.setWeakValuesArr();
		cachedValues.setWeakKeysM();
		caniocalNames.setWeakKeysM();
		storeCaniocalNames();
	}

	public function resetVariables() {
		storedVariables = [null];
		storedVariables.setWeakValuesArr();
		cachedValues = new haxe.ds.ObjectMap();
		cachedValues.setWeakKeysM();
		caniocalNames = new haxe.ds.ObjectMap();
		storeCaniocalNames();
	}

	function storeCaniocalNames() {
		recurseNames(0, "", untyped __lua__("_G"));

		// for (hookname => hookTbl in HookLib.GetTable()) {
		//     for (ident => hook in hookTbl) {
		// 		caniocalNames.set(hook,CHook(hookname,ident));
		//     }
		// }
	}

	function recurseNames(recurseDepth:Int, prevIndent:String, table:AnyTable) {
		if (recurseDepth > traverseDepth) {
			return;
		}
		for (k => v in table) {
			switch [Gmod.type(k), Gmod.type(v)] {
				case ["string", "function"]:
					caniocalNames.set(v, Canionical('$prevIndent$k'));
				case ["string", "table"]:
					if (v == untyped __lua__("_G"))
						continue;
					recurseNames(recurseDepth + 1, '$k.', v);

				default:
			}
		}
	}

	public function getVar(ind:Int) {
		return storedVariables[ind];
	}

	public function generateFakeChild(child:Dynamic, type:FakeChild) {
		final tab = Table.create();
		final meta = Table.create();
		final fakechild = Table.create();
		Lua.setmetatable(tab, meta);
		meta.__gmdebugFakeChild = fakechild;
		fakechild.child = child;
		fakechild.type = type;
		return tab;
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
		var uniqueName = if (Gmod.type(val) == "table" || Gmod.type(val) == "function") {
			switch (generateUniqueName(val)) {
				case Canionical(name):
					name;
				case Generated(name):
					'*$name';
			}
		} else {
			"";
		}
		var stringReplace = switch (ty) {
			case "table":
				'table: $uniqueName';
			case "function":
				'function: $uniqueName';
			case "string":
				val;
			case "number":
				Std.string(val);
			default:
				Gmod.tostring(val);
		};
		var generatedVariablesReference = generateVariablesReference(val, name);
		var obj:Variable = {
			name: name,
			type: ty,
			value: switch [addv.overrideValue != null, ty, addv.props] {
				case [true, _, _]:
					addv.overrideValue;
				// case [_,"table", NONE]:
				// 'table: ${generateUniqueName(val)}';
				case [_, "string", NONE]:
					'"$stringReplace"';
				case [_, _, NOQUOTE]:
					stringReplace;
				case [_, _, NOVALUE]:
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

	public function generateUniqueName(val:Dynamic):UniqueName {
		if (caniocalNames.exists(val)) {
			return caniocalNames.get(val);
		}
		var wordsStorage:WordsStorage = switch (Gmod.type(val)) {
			case "function":
				wordsStorageType.funcs;
			case "table":
				wordsStorageType.table;
			default:
				throw "generateUniqueName: Very much not handled";
		}

		return if (wordsStorage.toName.exists(val)) {
			Generated(wordsStorage.toName.get(val));
		} else {
			var chosenID = Math.floor(Math.random() * wordsStorage.wordsAvaliable.length);
			var chosen = wordsStorage.wordsAvaliable[chosenID];
			wordsStorage.wordsAvaliable.remove(chosen); // blah blah blah.
			wordsStorage.toName.set(val, chosen);
			Generated(chosen);
		}
	}

	public function generateVariablesReference(val:Dynamic, ?name:String):Int {
		if (val == null)
			return 0;
		var cacheID = cachedValues.get(val);
		return switch [Gmod.TypeID(val), cacheID] {
			case [null, _]:
				0;
			case [TYPE_ENTITY, null] if (!Gmod.IsValid(val)):
				0;
			case [TYPE_TABLE | TYPE_FUNCTION | TYPE_USERDATA | TYPE_ENTITY, null]:
				cachedValues.set(val, storedVariables.length);
				VariableReference.encode(Child(debugee.clientID, storedVariables.push(val) - 1));
			case [TYPE_TABLE | TYPE_FUNCTION | TYPE_USERDATA | TYPE_ENTITY, cacheID]:
				VariableReference.encode(Child(debugee.clientID, cacheID));
			default:
				0;
		};
	}
}

@:native("_G")
private extern class G {}

@:structInit
class AddVar {
	public var name:Dynamic;
	// std.string
	public var value:Dynamic;
	public var overrideValue:String = null;
	public var virtual:Null<Bool> = false;
	public var props:AddVarProperties = NONE;
}

enum AddVarProperties {
	NOQUOTE;
	NOVALUE;
	NONE;
}

enum FakeChild {
	Upvalues;
	Output;
	Output_Recurse; // this is getting silly, vscode.
}

enum UniqueName {
	Canionical(name:String);
	// Hook(hookname:String,uid:String);
	// Gamemode(gamemodeName:String,funcName:String);
	// Entity(entityName:String,funcName:String);
	// Effect(effectName:String,funcName:String);
	// Meta(metaName:String,funcName:String);
	Generated(name:String);
}
