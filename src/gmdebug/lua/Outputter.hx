package gmdebug.lua;

import gmdebug.lua.managers.VariableManager;
import gmod.Gmod;
import gmdebug.composer.*;
import haxe.Constraints.Function;
import lua.Table;
import gmod.libs.DebugLib;

typedef InitOutputter = {
	vm : VariableManager,
	debugee : Debugee
}

class Outputter {
	var ignoreTrace:Bool = false;
	
	final vm:VariableManager;

	final debugee:Debugee;

	public function new(initOutputter:InitOutputter) {
		vm = initOutputter.vm;
		debugee = initOutputter.debugee;
	}

	public function hookprint() {
		if (G.__oldprint == null) {
			G.__oldprint = G.print;
		}
		G.print = untyped __lua__("function (...) local succ,err = pcall({0},{1},true,{...}) if not succ then _G.__oldprint(...) _G.__oldprint(\"Debug output failed: \",err) end if {2}() then _G.__oldprint(...) end end",
			output, OutputEventCategory.Console, shouldForward);
	}

	function shouldForward() {
		return debugee.dapMode == Attach;
	}

	public function sendOutput(cat:OutputEventCategory,out:String) {
		final body:TOutputEvent = {
			category : cat,
			output: out + "\n"
		};
		final event = new ComposedEvent(EventString.output, body);
		final js = tink.Json.stringify((cast event : OutputEvent));
		debugee.send(js);
	} 

	function output(cat:OutputEventCategory, print:Bool, vargs:Table<Int, Dynamic>) {
		if (ignoreTrace || debugee.socket == null)
			return;
		ignoreTrace = true;
		var out:String = "";
		final arr:Array<Dynamic> = [];
		if (vargs != null) {
			for (dyn in vargs) {
				out += Gmod.tostring(dyn) + "\t";
				final varref = vm.generateVariablesReference(dyn);
				if (varref > 0) {
					arr.push(dyn);
				}
			}
		}
		out += "\n";
		final body:TOutputEvent = {
			category: Stdout,
			output: out,
			variablesReference: switch (arr.length) {
				case 0:
					null;
				default:
					vm.generateVariablesReference(arr);
			}
		}
		var lineInfo = DebugLib.getinfo(4, "Slf"); // + 1 for handler functions ect.
		if (print && lineInfo != null) {
			final meta = DebugLib.getmetatable(untyped __lua__("lineInfo.func"));
			if (meta != null) {
				if (meta.printHandler != null) {
					lineInfo = DebugLib.getinfo(6, "Slf");
				}
			}
			if (lineInfo != null && lineInfo.source != "") {
				final pth = @:nullSafety(Off) lineInfo.source.split("/");
				body.source = {
					name: pth[pth.length - 1],
					path: debugee.normalPath(lineInfo.source),
				};
				body.line = lineInfo.currentline;
			}
		}
		final event = new ComposedEvent(EventString.output, body);
		final js = tink.Json.stringify((cast event : OutputEvent));
		debugee.send(js);
		ignoreTrace = false;
	}
}

@:native("_G") private extern class G {
	static var __oldprint:Null<Function>;

	static var print:Function;
}
