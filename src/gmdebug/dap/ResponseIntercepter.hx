package gmdebug.dap;

import gmdebug.composer.RequestString;
import haxe.ds.ArraySort;

interface ResponseIntercepter {
    function intercept(ceptedRequest:Response<Dynamic>, threadId:Int):Void;
}

class ResponseIntercepterDef implements ResponseIntercepter {

    final luaDebug:LuaDebugger;

    final pathManager:PathManager;

    public function new(_luaDebug:LuaDebugger,_pathManager:PathManager) {
        luaDebug = _luaDebug;
        pathManager = _pathManager;
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
            case stackTrace:
                final stackTraceResp:StackTraceResponse = ceptedResponse;
                for (stackFrame in stackTraceResp.body.stackFrames) {
                    final pth = stackFrame.source.path;
                    stackFrame.source.path = pathManager.gmodPathToRealPath(pth);
                }
            default:
        }
    }


}
