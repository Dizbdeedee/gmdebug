package gmdebug.lua;

import gmod.helpers.LuaArray;
import lua.TableTools;
import gmod.libs.MathLib;
import gmod.libs.TableLib;
import haxe.ds.ObjectMap;
import gmdebug.lua.managers.VariableManager;
import gmod.Gmod;
import gmdebug.composer.*;
import gmdebug.Cross.OUTPUT_INTERCEPTED;
import haxe.Constraints.Function;
import lua.Table;
import gmod.libs.DebugLib;

using Lambda;
using StringTools;

typedef InitOutputter = {
    vm : VariableManager,
    debugee : Debugee
}

class Outputter {
    var ignoreTrace:Bool = false;

    final vm:VariableManager;

    final debugee:Debugee;

    final outputOffset:haxe.ds.ObjectMap<Function, Int> = new ObjectMap();

    var msgID = 0;

    final cacheOutputResults:Array<Dynamic> = [];

    public function new(initOutputter:InitOutputter) {
        vm = initOutputter.vm;
        debugee = initOutputter.debugee;
    }

    public function hookPrint() {
        if (G.__oldprint == null) {
            G.__oldprint = G.print;
        }
        G.print = printFunc;
    }

    public function unhookPrint() {
        if (G.__oldprint == null) {
            G.print = G.__oldprint;
        }
    }

    public function sendOutput(cat:OutputEventCategory,out:String) {
        final body:TOutputEvent = {
            category : cat,
            output: out  //no newlines from our end
        };
        final event = new ComposedEvent(EventString.output, body);
        final js = tink.Json.stringify((cast event : OutputEvent));
        debugee.send(js);
    }


    function printFunc(...rest:Dynamic) {
        if (ignoreTrace) {
            G.__oldprint(rest);
            return;
        }
        ignoreTrace = true;
        var sh = 2; //2 referring to the one above
        final info = DebugLib.getinfo(sh,"f");
        if (info == null) {
            trace("Func does not exist...");
            ignoreTrace = false;
            return;
        }
        if (outputOffset.get(info.func) != null) {
            sh += outputOffset.get(info.func);
        }
        sh += 1;//pcall, output
        printOutput(sh,rest.toArray());
        var hookedRest = rest.prepend(OUTPUT_INTERCEPTED);
        G.__oldprint(TableTools.unpack(cast hookedRest));
        ignoreTrace = false;
    }

    function printOutput(sh:Int,vargs:Array<Dynamic>) {
        var out:String = "";
        for (dyn in vargs) {
            out += Gmod.tostring(dyn) + "\t";
        }
        // out += "\n"; //mmm...

        final body:TOutputEvent = {
            category: Stdout,
            output: out,
            variablesReference: null
        }
        var lineInfo = DebugLib.getinfo(sh, "Slf"); // + 1 for handler functions ect.
        if (lineInfo != null && lineInfo.source != "") {
            final pth = @:nullSafety(Off) lineInfo.source.split("/");
            body.source = {
                name: pth[pth.length - 1],
                path: debugee.normalPath(lineInfo.source),
            };
            body.line = lineInfo.currentline;

        }
        final event = new ComposedEvent(EventString.output, body);
        final js = tink.Json.stringify((cast event : OutputEvent));
        debugee.send(js);
        final vargsNonString = vargs.filter((dyn) -> Gmod.type(dyn) != "string");
        final vargsNonStringValue = new LuaArray();
        vargsNonString.iter((item) -> vargsNonStringValue.push(item));
        final variablesReference = switch (vargsNonString.length) {
            case 0:
                null;
            default:
                vm.generateVariablesReference(vm.generateFakeChild(vargsNonStringValue,Output));
        }
        cacheOutputResults.push(vargs); //leaky weaky
        cacheOutputResults.push(vargsNonStringValue);
        if (variablesReference != null) {
            final event = new ComposedEvent(EventString.output, {
                category: Stdout,
                output: "",
                variablesReference: variablesReference
            });
            final js = tink.Json.stringify((cast event : OutputEvent));
            debugee.send(js);
        }
        ignoreTrace = false;
    }
}

@:native("_G") private extern class G {
    static var __oldprint:Null<Function>;

    // @:native("__oldprint")
    // static function oldPrint(rest:haxe.extern.Rest<Dynamic>):Void;

    static var print:Function;
}
