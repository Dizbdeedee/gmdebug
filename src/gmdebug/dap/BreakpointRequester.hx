package gmdebug.dap;

import gmdebug.dap.clients.BaseConnected;
import haxe.Timer;
import gmdebug.PromiseUtil.PromiseArray;
import gmdebug.dap.GmodPath;
import gmdebug.dap.clients.ClientStorage;

using tink.CoreApi;

interface BreakpointRequester {
	function processBreakpoint(breakpoint:SetBreakpointsRequest):Void;

	function processBreakpointResponse(resp:SetBreakpointsResponse, clientID:Int):Void;
}

class BreakpointRequesterDef implements BreakpointRequester {
	final fileLookup:FileLookup;

	final breakpointLookup:Map<String, SetBreakpointsRequest> = [];

	final promise:Map<Int, Promise<Array<SetBreakpointsResponse>>> = [];

	final promiseTriggers:Map<String, PromiseTrigger<SetBreakpointsResponse>> = [];

	final clientStorage:ClientStorage;

	final luaDebugger:LuaDebugger;

	public function new(_fileLookup:FileLookup, _luaDebugger:LuaDebugger, _clientStorage:ClientStorage) {
		fileLookup = _fileLookup;
		luaDebugger = _luaDebugger;
		clientStorage = _clientStorage;
	}

	public function processBreakpoint(breakpoint:SetBreakpointsRequest) {
		var idReq = breakpoint.seq;
		var path = breakpoint.arguments.source.path;
		var promiseArr = new PromiseArray<SetBreakpointsResponse>();
		for (client in clientStorage.getClients()) {
			var clientID = client.clID;
			var combinedID = '$idReq|$clientID';
			var pt = setupPromiseBreakpointResponse(combinedID);
			breakpointLookup.set(combinedID, breakpoint);
			promiseArr.add(pt.asPromise());
			clientStorage.sendAny(client.clID, breakpoint);
		}

		var allResults = promiseArr.inParallel(null)
			.handle((results) -> {
				switch (results) {
					case Success(data):
						//*ncp try the simplest case first
						var bp = data[0];
						trace("*ncp SENT RESPONSE");
						luaDebugger.sendResponse(bp);
					case Failure(failure):
						trace("*ncp FAILED TO SEND RESPONSE");
				}
			});
	}

	function setupPromiseBreakpointResponse(combID:String,
			timeout:Int = 500):PromiseTrigger<SetBreakpointsResponse> {
		var promiseTrigger = new PromiseTrigger();
		promiseTriggers.set(combID, promiseTrigger);
		Timer.delay(() -> {
			promiseTrigger.reject(new Error(0, "Timeout..."));
		}, timeout);
		return promiseTrigger;
	}

	public function processBreakpointResponse(resp:SetBreakpointsResponse, clientID:Int) {
		var idReq = resp.request_seq;
		var combinedID = '$idReq|$clientID';
		var pt = promiseTriggers.get(combinedID);
		if (pt == null) {
			trace('*ncp $combinedID PT IS NULL processBreakpointResponse');
		}
		promiseTriggers.get(combinedID)
			.resolve(resp);
	}
}
