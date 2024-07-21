package gmdebug.dap;

import gmdebug.dap.clients.BaseConnected;
import haxe.Timer;
import gmdebug.PromiseUtil.PromiseArray;
import gmdebug.dap.GmodPath;
import gmdebug.dap.clients.ClientStorage;
import haxe.io.Path as HxPath;

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
		//TODO validate
		var idReq = breakpoint.seq;
		final source = breakpoint.arguments.source;
		if (source == null) {
			trace("Unexpected BreakpointRequester/processBreakpoint: source is null");
			return;
		}
		var path = source.path;
		if (path == null) {
			trace("Unexpected BreakpointRequester/processBreakpoint: path is null");
			return;
		}
		if (!HxPath.isAbsolute(path)) {
			//ok.. let's try from project folder
			GMDNormalAbsPath.toNormalFromRel(path, );
		}
		var cresult = fileLookup.getContextForAbsPath(null);
		var gmdPath = GMDNormalAbsPath.toNormal("asdfdsaaf");
		// switch (cresult) {
		// 	case Some(_, GmodPath.pathToGmodPath(_, path) => Some(gmodpath)):
		// 		source.path = gmodpath;
		// 		trace('*ncp Attempt to find gmodPath for breakpoint success ${source.path}');
		// 	default:
		// 		trace("*ncp could not lookup gmodPath for breakpoint request");
		// 		// send dummy breakpoint, or panic. Or something.
		// }
		var promiseArr = new PromiseArray<SetBreakpointsResponse>();
		var lookupAbs = fileLookup.getContextForAbsPath(null);
		trace('*ncp $lookupAbs');
		for (client in clientStorage.getClients()) {
			var clientID = client.clID;
			var combinedID = '$idReq|$clientID';
			var pt = setupPromiseBreakpointResponse(combinedID);
			breakpointLookup.set(combinedID, breakpoint);
			promiseArr.add(pt.asPromise());
			clientStorage.sendAny(client.clID, breakpoint);
			break; //*ncp temp
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

	function cloneBreakpoint(breakpoint:SetBreakpointsRequest):SetBreakpointsRequest {
		return cast {

		}
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
		trace('*ncp PROCESS BREAKPOINT RESPONSE RUNNING FOR $clientID');
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
