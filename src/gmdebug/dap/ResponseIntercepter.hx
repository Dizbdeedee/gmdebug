package gmdebug.dap;

import gmdebug.composer.RequestString;
import haxe.ds.ArraySort;
import node.Fs;
import node.NodeCrypto;

interface ResponseIntercepter {
	function intercept(ceptedRequest:Response<Dynamic>, threadId:Int):Void;
}

class ResponseIntercepterDef implements ResponseIntercepter {
	final fileTracker:FileTracker;

	public function new(_fileTracker:FileTracker) {
		fileTracker = _fileTracker;
	}

	public function intercept(ceptedResponse:Response<Dynamic>, threadId:Int) {
		final command:AnyRequest = ceptedResponse.command;
		switch (command) {
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
			case stackTrace:
				final stackTraceResp:StackTraceResponse = ceptedResponse;
				final stackTraces = stackTraceResp.body.stackFrames;
				for (stack in stackTraces) {
					if (stack.source == null)
						continue;
					final newPth = switch (fileTracker.findAbsLuaFile(stack.source.path, threadId)) {
						case Some(abspth):
							lookupFromAbs(abspth);
						default:
							// ERROR! ahhhh
							trace("COULD NOT LOOKUP PATH!!!");
							stack.source.path;
					}
					stack.source.path = newPth;
				}
			default:
		}
	}

	function lookupFromAbs(abs:String) {
		final result = switch (fileTracker.lookupFile(abs)) {
			case SUPERIOR_FILE(superiorFile):
				trace("lookupFromAbs/ using superiror file");
				superiorFile;
			case CANT_FIND:
				trace("lookupFromAbs/ can't find calculated md5 succ");
				abs;
			case NOT_STORED:
				trace("lookupFromAbs/ none");
				final hshFunc = NodeCrypto.createHash("md5");
				final contents = Fs.readFileSync(abs, {encoding: 'utf8'});
				// trace(abs);
				// trace("-----------------");
				// trace(contents.toString());
				// trace("-----------------");
				hshFunc.update(contents.toString());
				fileTracker.storeLookupFile(abs, hshFunc.digest('hex'));
				null;
		}
		if (result != null)
			return result;
		return switch (fileTracker.lookupFile(abs)) {
			case SUPERIOR_FILE(superiorFile):
				trace("lookupFromAbs/ looked up calculated md5 lookup 2");
				superiorFile;
			case CANT_FIND:
				trace("lookupFromAbs/ can't find calculated md5 lookup 2");
				abs;
			case NOT_STORED:
				trace("lookupFromAbs/ something went bery wrong");
				throw "lookupFromAbs/ something went bery wrong";
				return null;
		}
	}
}
