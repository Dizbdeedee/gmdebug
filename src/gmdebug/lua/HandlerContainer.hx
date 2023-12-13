package gmdebug.lua;

import gmdebug.lua.debugcontext.DebugContext;
import haxe.Exception;
import gmdebug.lua.managers.FunctionBreakpointManager;
import gmdebug.lua.handlers.HDisconnect;
import gmdebug.composer.RequestString;
import gmdebug.lua.managers.VariableManager;
import gmdebug.lua.handlers.*;
import gmdebug.lua.handlers.IHandler.HandlerResponse;
import gmdebug.lua.managers.BreakpointManager;
import gmdebug.lib.lua.Protocol;

using gmdebug.composer.ComposeTools;

import String;

using Safety;
using Lambda;

typedef InitHandlerContainer = {
	vm:VariableManager,
	bm:BreakpointManager,
	fbm:FunctionBreakpointManager,
	debugee:Debugee,
	exceptions:Exceptions,
	sc:SourceContainer
}

class HandlerContainer {
	var handlerMap:haxe.ds.StringMap<IHandler<Request<Dynamic>>> = new haxe.ds.StringMap();

	public function new(initHandlerContainer:InitHandlerContainer) {
		handlerMap.set("_continue", new HContinue(initHandlerContainer));
		handlerMap.set(disconnect, new HDisconnect());
		handlerMap.set(stackTrace, new HStackTrace(initHandlerContainer));
		handlerMap.set(next, new HNext(initHandlerContainer));
		handlerMap.set(pause, new HPause(initHandlerContainer));
		handlerMap.set(stepIn, new HStepIn(initHandlerContainer));
		handlerMap.set(stepOut, new HStepOut(initHandlerContainer));
		handlerMap.set(variables, new HVariables(initHandlerContainer));
		handlerMap.set(setBreakpoints, new HSetBreakpoints(initHandlerContainer));
		handlerMap.set(setFunctionBreakpoints, new HSetFunctionBreakpoints(initHandlerContainer));
		handlerMap.set(setExceptionBreakpoints, new HSetExceptionBreakpoints(initHandlerContainer));
		handlerMap.set(evaluate, new HEvaluate(initHandlerContainer));
		handlerMap.set(configurationDone, new HConfigurationDone(initHandlerContainer));
		handlerMap.set(scopes, new HScopes(initHandlerContainer));
		handlerMap.set(loadedSources, new HLoadedSources(initHandlerContainer));
	}

	public function handlers(req:Request<Dynamic>):HandlerResponse {
		final result = if (req.command == "continue") {
			handlerMap.get("_continue");
		} else {
			handlerMap.get(req.command);
		}
		if (result == null) {
			trace('No such command ${req.command}');
			throw new Exception('No such command ${req.command}');
		}
		var resultHandler = DebugContext.debugContext({result.handle(req);}); // oh yeah. TODO
		return resultHandler;
	}
}

typedef Item = {
	name:String,
	type:String,
	?value:String,
	?variablesReference:Int
}

enum abstract EvalCommand(String) from String {
	var profile;
}
