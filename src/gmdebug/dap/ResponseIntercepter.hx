package gmdebug.dap;

import haxe.ds.ArraySort;
import node.Fs;
import node.NodeCrypto;
import gmdebug.dap.BreakpointRequester;
import gmdebug.dap.FileLookup;

interface ResponseIntercepter {
	function intercept(ceptedRequest:Response<Dynamic>, threadId:Int):ResponseIntercepterResult;
}

class ResponseIntercepterDef implements ResponseIntercepter {
	final fileLookup:FileLookup;

	final breakpointRequester:BreakpointRequester;

	public function new(_fileLookup:FileLookup, _breakpointRequester:BreakpointRequester) {
		fileLookup = _fileLookup;
		breakpointRequester = _breakpointRequester;
	}

	public function intercept(ceptedResponse:Response<Dynamic>, threadId:Int):ResponseIntercepterResult {
		final command:AnyRequest = ceptedResponse.command;
		return switch (command) {
			case variables:
				final variablesResp:VariablesResponse = ceptedResponse;
				ArraySort.sort(variablesResp.body.variables, (a, b) -> {
					return switch [a.name, b.name] {
						case [null, null]:
							0;
						case [null, _]:
							1;
						case [_, null]:
							-1;
						case [a, b] if (a > b):
							1;
						case [a, b] if (b > a):
							-1;
						default:
							0;
					}
				});
				Send;
			case stackTrace:
				final stackTraceResp:StackTraceResponse = ceptedResponse;
				final stackTraces = stackTraceResp.body.stackFrames;
				for (stack in stackTraces) {
					final source = stack.source;
					if (source == null)
						continue;
					final gmodPath:GmodPath = cast source.path;
					if (gmodPath == null)
						continue;
					final allPaths = fileLookup.lookupAllLocations(gmodPath);
					var backup = "";
					var set = false;
					for (loc in allPaths) {
						switch (loc) {
							case PROJECT(str):
								trace("*ncp Found project path: " + str);
								source.path = str;
								set = true;
								break;
							case SERVER(str):
								backup = str;
							default:
						}
					}
					if (!set && backup != "") {
						trace("*ncp Found server path: " + backup);
						source.path = backup;
					}
				}
				Send;
			case setBreakpoints:
				breakpointRequester.processBreakpointResponse(cast ceptedResponse, threadId);
				NoSend;
			default:
				Send;
		}
	}
}

enum ResponseIntercepterResult {
	Send;
	NoSend;
}
