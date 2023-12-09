package gmdebug.dap;

import gmdebug.composer.RequestString;
import haxe.ds.ArraySort;

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
                ArraySort.sort(variablesResp.body.variables,(a,b) -> {
                    return switch [a.name,b.name] {
                        case [null,null]:
                            0;
                        case [null,_]:
                            1;
                        case [_,null]:
                            -1;
                        case [a,b] if (a > b):
                            1;
                        case [a,b] if (b > a):
                            -1;
                        default:
                            0;
                    }
                });
                // for (v in variablesResp.body.variables) {

                // }
            case stackTrace:
                final stackTraceResp:StackTraceResponse = ceptedResponse;
                final stackTraces = stackTraceResp.body.stackFrames;
                for (stack in stackTraces) {
                    if (stack.source == null) continue;
                    newpth = switch(fileTracker.findAbsLuaFile(stack.source.path,threadId)) {
                        case Some(abspth):
                            lookupFromAbs(abspth);
                        default:
                            //ERROR! ahhhh
                            trace("COULD NOT LOOKUP PATH!!!");
                            stack.source.path;
                    }
                }
            default:
        }
    }

    function lookupFromAbs(abs:String) {
        return switch (fileTracker.lookupFile(abs)) {
            case Some(superiorFile):
                superiorFile;
            case None:
                final hshFunc = NodeCrypto.createHash("md5");
                final contents = Fs.readFileSync(abs);
                hshFunc.update(contents.toString());
                fileTracker.storeLookupFile(abs,hshFunc.digest());
                switch (fileTracker.lookupFile(abs)) {
                    case Some(superiorFile):
                        superiorFile;
                    default:
                        abs;
                }
        }
    }
}
