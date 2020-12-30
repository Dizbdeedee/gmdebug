package gmdebug.lua.handlers;

class HEvaluate implements IHandler<EvaluateRequest> {

    public function new() {

    }

    inline function translateEvalError(err:String) {
        return NativeStringTools.gsub(err,'^%[string %"X%"%]%:%d+%: ',"");
    }

    function createEvalEnvironment(stackLevel:Int):AnyTable {
        final env = Table.create();
        final unsettables:AnyTable = Table.create();
        final set = function(k,v) {
            Reflect.setField(unsettables,k,v);
        }
        var info = DebugLib.getinfo(stackLevel + 2,"f"); //used to be 1
        var fenv:Null<AnyTable> = null;
        if (info != null && info.func != null) {
            for (i in 1...9999) {
                final func = info.func;//otherwise _hx_bind..?
                final upv = DebugLib.getupvalue(func,i);
                if (upv.a == null) break;
                set(upv.a,upv.b);
            }
            final func = info.func;//otherwise _hx_bind..?
            fenv = DebugLib.getfenv(func);
            // Gmod.print(fenv);
        }
        for (i in 1...9999) {
            final lcl = DebugLib.getlocal(stackLevel + 2,i); //used to be 1 :)
            if (lcl.a == null) break;
            set(lcl.a,lcl.b);
        }
        var metatable:AnyTable = Table.create();
        metatable.__newindex = (t,k,v) -> {
            if (Lua.rawget(unsettables,k) != null) Gmod.error("Cannot alter upvalues and locals",2);
            else untyped __lua__("_G")[k] = v;
        }
        metatable.__index = unsettables;
        var unsetmeta:AnyTable = Table.create();
        unsetmeta.__index = fenv.or(untyped __lua__("_G"));
        Gmod.setmetatable(env,metatable);
        Gmod.setmetatable(unsettables,unsetmeta);
        return env;
    }

    function processCommands(x:EvalCommand) {
        switch (x) {
            case profile:
                DebugLoopProfile.beginProfiling();
        }
    }
    
    public function handle(:EvaluateRequest):HandlerResponse {
        final args = x.arguments.unsafe();
        final fid:Null<FrameID> = args.frameId;
        if (args.expression.charAt(0) == "#") {
            processCommands(args.expression.substr(1));
        }
        var expr = Util.processReturnable(args.expression);
        if (args.context == Hover) {
            expr = NativeStringTools.gsub(expr,":","."); //a function call is probably not intended from a hover.
        }
        trace('expr : $expr');
        final resp:ComposedProtocolMessage = switch (Util.compileString(expr,"GmDebug")) {
            case Error(err):
                x.composeFail(translateEvalEr/proror(err));
            case Success(func):
                if (fid != null) {
                    final eval = createEvalEnvironment(fid.getValue().actualFrame);
                    Gmod.setfenv(func,eval);
                }
                switch (Util.runCompiledFunction(func)) {
                    case Error(err):
                        x.composeFail(translateEvalError(err));
                    case Success(result):
                        final item = genvar({
                            name : "",
                            value : result
                        });
                        x.compose(evaluate,{
                            result: item.value,
                            type: item.type,
                            variablesReference: item.variablesReference,
                        });
                }
        }
        resp.send();
        return WAIT;
    }
}