package gmdebug.lua;

import gmod.libs.DebugLib;
import gmod.libs.FileLib;
import gmod.libs.GamemodeLib;
import lua.Debug;
import gmod.stringtypes.Hook.GMHook;
import lua.Lua;
import haxe.Constraints.Function;
import gmod.libs.HookLib;
import gmod.libs.Scripted_entsLib;
import gmod.Gmod;
import haxe.ds.ObjectMap;
import haxe.io.Path as HxPath;

using Safety;
using gmod.helpers.WeakTools;
class Exceptions {
	public static final exceptFuncs = getexceptFuncs();

	public static final debugNames:ObjectMap<Dynamic, String> = new ObjectMap<Dynamic,String>();


	static function getexceptFuncs():ObjectMap<Dynamic, Dynamic> {
		if (G.exceptFuncs == null) {
			G.exceptFuncs = new ObjectMap<Dynamic, Dynamic>();
		}
		G.exceptFuncs.setWeakKeyValuesM();
		return G.exceptFuncs;
	}

	public static function tryHooks() {

		unhookGamemodeHooks();
		unhookEntityHooks();
		unhookInclude();		
		hookGamemodeHooks();
		hookEntityHooks();
		hookInclude();
		final result = exceptFuncs.exists(null);
		trace(result);
	}

	public static inline function isExcepted(x:Function):Bool {
		return exceptFuncs.exists(x);
	}

	static function addExcept(x:Function):Function {
		var func = untyped __lua__("function (...) local success,vargs = xpcall({0},{1},...) if success then return vargs else print(\"baddy bad!\") error(vargs,99) end end",
			x,
			G.__gmdebugTraceback); 
		exceptFuncs.set(func, x);
		return func;
	}

	static function getOldFunc(hook:Function) {
		return exceptFuncs.get(hook);

	}

	public static function hookGamemodeHooks() {
		for (hookname => hook in HookLib.GetTable()) {
			for (ident => hooks in hook) {
				if (shouldExcept(hooks)) {
					// debugNames.set(hooks,ident);
					HookLib.Add(hookname, ident, addExcept(hooks));
				}
			}
		}
		if (Gmod.GAMEMODE != null) {
			for (ind => gm in Gmod.GAMEMODE) {
				if (shouldExcept(gm)) {
					// debugNames.set(gm,ind);
					Gmod.GAMEMODE[cast ind] = addExcept(gm);
				}
				
			}
		}
		
		G.oldGamemodeRegister = GamemodeLib.Register;
		untyped GamemodeLib.Register = (gm, name, derived) -> {
			for (ind => val in gm) {
				if (shouldExcept(val)) {
					gm[ind] = addExcept(val);
				}
			}
			G.oldGamemodeRegister(gm, name, derived);
		}
		
	}

	static function hookInclude() {
		G.oldInclude = Gmod.include;
		untyped Gmod.include = (str) -> {
			final info = DebugLib.getinfo(2,"S");
			final currentPath = info.source.substring(1);
			final currentDir = HxPath.directory(currentPath);
			final findPth = HxPath.join([currentDir,str]);
			final relative = FileLib.Exists(findPth,GAME);
			final nonrelative = FileLib.Exists(str,LUA);
			trace('path: $str relative: $relative nonrelative: $nonrelative');
			return G.oldInclude(str);
			final compileFunc = switch [relative,nonrelative] {
				case [true,_]:
					trace("relative");
					Gmod.CompileString(FileLib.Read(findPth,GAME), findPth, false);
				case [_,true]:
					trace("nonrelative");
					Gmod.CompileString(FileLib.Read(str,LUA), str, false);
				default:
					trace('Could not catch exceptions for included file : $str');
					return G.oldInclude(str);
			}
			if (Lua.type(compileFunc) == "string") {
				// trace("Could not compile file...);
			} else {
				final fun = addExcept(compileFunc);
				fun();
			}
			return G.oldInclude(str);
		};
		
	}

	static function unhookInclude() {
		if (G.oldInclude != null) {
			untyped Gmod.include = G.oldInclude;
		}
	}

	// public static function 
	
	public static function createWrapperTable(target:AnyTable) {
		final wrapper:AnyTable = lua.Table.create();
		final meta:AnyTable = lua.Table.create();
		meta.__index = target;
		meta.__newindex = (_,ind:Dynamic,val) -> {
			final newVal:Dynamic = if (Gmod.TypeID(val) == TYPE_FUNCTION && shouldExcept(val)) {
				Lua.print("update ",ind);
				addExcept(val);
			} else {
				Lua.print('not updating... $ind reason ${Gmod.TypeID(val) == TYPE_FUNCTION} ${shouldExcept(val)}');
				val;
			}
			target[ind] = newVal;
		}
		Lua.setmetatable(wrapper,meta);
		return wrapper;
	}

	public static function hookEntityHooks() {
		//afteraction
		for (entName in Scripted_entsLib.GetList().keys()) {
			final entTbl = Scripted_entsLib.GetStored(entName);
			for (ind => val in entTbl.t) {
				if (shouldExcept(val)) {
					// debugNames.set(val,ind);
					// trace(entTbl);

					entTbl.t[ind] = addExcept(val);
				
				}
			}
			// entTbl.t = cast createWrapperTable(entTbl.t);
		}
		G.oldEntityRegister = Scripted_entsLib.Register;
		untyped Scripted_entsLib.Register = (ENT,name) -> {
			for (ind => val in ENT) {
				if (shouldExcept(val)) {
					ENT[ind] = addExcept(val);
				}
			}
			G.oldEntityRegister(ENT,name);
		}
		
	}

	public static function hookPanels() {
		// TODO
	}

	static inline function shouldExcept(x:Dynamic) {
		return Lua.type(x) == "function" && !isExcepted(x);
	}

	static inline function shouldUnExcept(x:Dynamic) {
		return Lua.type(x) == "function" && isExcepted(x);
	}

	public static function unhookGamemodeHooks() {
		for (hookname => hook in HookLib.GetTable()) {
			for (ident => hooks in hook) {
				if (shouldUnExcept(hooks)) {
					HookLib.Add(hookname, ident, getOldFunc(hooks));
					
					exceptFuncs.remove(hooks);
				}
			}
		}
		if (Gmod.GAMEMODE != null) {
			for (ind => gm in Gmod.GAMEMODE) {
				if (shouldUnExcept(gm)) {
					
					Gmod.GAMEMODE[ind] = getOldFunc(gm);
					exceptFuncs.remove(gm);
				}
			}
		}
		if (G.oldGamemodeRegister != null) {
			untyped GamemodeLib.Register = G.oldGamemodeRegister;
		}
	}

	public static function unhookEntityHooks() {
		for (entName in Scripted_entsLib.GetList().keys()) {
			final entTbl = Scripted_entsLib.GetStored(entName);
			for (ind => val in entTbl.t) {
				if (shouldUnExcept(val)) {
					entTbl.t[ind] = getOldFunc(val);
					exceptFuncs.remove(val);
				}
			}
		}
		if (G.oldEntityRegister != null) {
			untyped Scripted_entsLib.Register = G.oldEntityRegister;
		}
	}
}

@:native("_G")
private extern class G {
	@:native("__exceptFuncs")
	static var exceptFuncs:haxe.ds.ObjectMap<Dynamic, Dynamic>;

	@:native("__oldFuncs")
	static var oldFuncs:Array<Function>;

	@:native("__oldGamemodeRegister")
	static var oldGamemodeRegister:Any;

	@:native("__oldEntityRegister")
	static var oldEntityRegister:Any;

	@:native("__oldInclude")
	static var oldInclude:Any;

	static function __gmdebugTraceback():Void;
}