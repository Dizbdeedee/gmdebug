package gmdebug.dap;

import gmdebug.Util.recurseCopy;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import gmdebug.composer.RequestString;
import js.Node;
import js.node.Buffer;
import js.node.child_process.ChildProcess;
import js.node.fs.Stats;
import js.node.Fs;
import gmdebug.composer.*;
import vscode.debugProtocol.DebugProtocol;
import gmdebug.VariableReference;
import gmdebug.GmDebugMessage;
import haxe.io.Path as HxPath;
using gmdebug.composer.ComposeTools;
using gmdebug.dap.DapFailure; 
using Lambda;
using Safety;
using StringTools;


class RequestRouter {

	var luaDebug:LuaDebugger;

	var clients:ClientStorage;

	var prevRequests:PreviousRequests;

	public function new(luaDebug:LuaDebugger,clients:ClientStorage,prevRequests:PreviousRequests) {
		this.luaDebug = luaDebug;
		this.clients = clients;
		this.prevRequests = prevRequests;
	}

	public function route(req:Request<Dynamic>) {
		final command:AnyRequest = req.command;
		switch (command) {
			case pause | stackTrace | stepIn | stepOut | next | "continue":
				final id = (req : HasThreadID).arguments.threadId;
				clients.sendAny(id, req);
			case attach:
				h_attach(req);
			case disconnect:
				h_disconnect(req);
			case launch:
				h_launch(req);
			case scopes:
				h_scopes(req);
			case variables:
				h_variables(req);
			case evaluate:
				h_evaluate(req);
			case setBreakpoints:
				prevRequests.update(req);
				clients.sendAll(req);	
			// h_setBreakpoints(req);
			case setExceptionBreakpoints:
				prevRequests.update(req);
				clients.sendAll(req);
			case setFunctionBreakpoints:
				prevRequests.update(req);
				clients.sendAll(req);
			case initialize:
				h_initialize(req);
			case configurationDone:
				clients.sendServer(req);
			case threads:
				h_threads(req);
			case loadedSources | modules | goto | gotoTargets | breakpointLocations | _continue: // _continue: ARRRRGGGHHHH
				clients.sendServer(req);
		}
	}

	function h_threads(req:ThreadsRequest) {
		final threadArr = [{name: "Server", id: 0}];
		for (cl in clients.getClients()) {
			threadArr.push({
				name : cl.gmodName,
				id : cl.clID
			});
		} 
		req.compose(threads, {threads: threadArr}).send(luaDebug);
	}

	function h_disconnect(req:DisconnectRequest) {
		clients.sendAll(req);
		req.compose(disconnect).send(luaDebug);
		luaDebug.shutdown();
	}

	function h_variables(req:VariablesRequest) {
		final ref:VariableReference = req.arguments.variablesReference;
		if ((ref : Int) <= 0) {
			trace("invalid variable reference");
			req.compose(variables, {variables: []}).send(luaDebug);
			return;
		}
		switch (ref.getValue()) {
			case Global(clID, _) | FrameLocal(clID, _, _) | Child(clID, _):
				clients.sendAny(clID, req);
		}
	}

	function h_evaluate(req:EvaluateRequest) {
		final expr = req.arguments.expression;
		if (expr.charAt(0) == "/") {
			switch (luaDebug.dapMode) {
				case LAUNCH(child):
					final actual = expr.substr(1);
					child.write(actual + "\n");
					req.compose(evaluate, {
						result: "",
						variablesReference: 0
					}).send(luaDebug);
					return;
				default:
			}
		}
		final client = switch (req.arguments.frameId) {
			case null:
				0; // run as server if not in frame context. might cause issues...
			case frame:
				(frame : FrameID).getValue().clientID;
		}
		clients.sendAny(client, req);
	}

	function h_initialize(req:InitializeRequest) {
		final response:InitializeResponse = {
			seq: 0, // it gets ignored anyway
			request_seq: req.seq,
			command: "initialize",
			type: Response,
			body: {},
			success: true,
		}
		response.body.supportsConfigurationDoneRequest = true;
		response.body.supportsFunctionBreakpoints = true;
		response.body.supportsConditionalBreakpoints = true;
		response.body.supportsEvaluateForHovers = true;
		response.body.supportsLoadedSourcesRequest = true;
		response.body.supportsFunctionBreakpoints = true;
		response.body.supportsDelayedStackTraceLoading = true;
		response.body.supportsBreakpointLocationsRequest = false;
		luaDebug.sendResponse(response);
	}

	function h_launch(req:GmDebugLaunchRequest) {
		luaDebug.initFromRequest(req,req.arguments);
	}

	function h_scopes(req:ScopesRequest) {
		final client = (req.arguments.frameId : FrameID).getValue().clientID; // mandatory
		clients.sendAny(client, req);
	}

	function h_attach(req:GmDebugAttachRequest) {
		req.composeFail("Gmdebug does not currently support attach requests",
		{
			id : 15,
			format : "Gmdebug does not currently support attach requests"
		}).send(luaDebug);
		return;
	}
	
}

private typedef HasThreadID = {
	arguments:{
		threadId:Int
	}
}





