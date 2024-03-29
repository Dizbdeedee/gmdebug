package gmdebug.lua;

import haxe.Constraints.Function;
import lua.Lua;
import gmod.libs.DebugLib;
import gmod.Gmod;

using Safety;

enum CompileResult {
	Error(err:String);
	Success(compiledFunc:Function);
}

enum RunResult {
	Error(err:String);
	Success(dyn:Dynamic);
}

class Util {
	static final CSOURCE = "=[C]";

	public static inline function isCSource(source:String) {
		return source == CSOURCE;
	}

	public static function compileString(eval:String, errorPrefix:String):CompileResult {
		return switch (runCompiledFunction(Gmod.CompileString, eval, errorPrefix, false)) {
			case Success(result) if (Lua.type(result) == "string"):
				Error(result);
			case Error(str):
				Error(str);
			case Success(result):
				Success(result);
		}
	}

	public static function runCompiledFunction(compiledFunc:Function, ?a:Dynamic, ?b:Dynamic, ?c:Dynamic,
			?d:Dynamic, ?e:Dynamic) {
		@:nullSafety(Off) final runResult = Lua.pcall(compiledFunc, a, b, c, d, e);
		return if (runResult.status) {
			Success(runResult.value);
		} else {
			Error(runResult.value);
		}
	}

	public static inline function processReturnable(expr:String):String {
		return if (expr.charAt(0) == "!") {
			expr.substr(1);
		} else {
			'return ( $expr )';
		}
	}

	public static function traceStack(?desired:Int) {
		trace('0 | This func... (getinfo + 1)');
		for (i in 1...99999) {
			var info = DebugLib.getinfo(i, "lnSfu");
			if (info == null)
				break;
			var target = if (i == desired) {
				"| TARGET";
			} else {
				"|";
			}
			trace('$i | ${info.name} $target');
		}
	}
}
