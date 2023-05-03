package gmdebug.dap;

import gmdebug.composer.RequestString;
import haxe.ds.ArraySort;

interface ResponseIntercepter {
    function intercept(ceptedRequest:Response<Dynamic>, threadId:Int):Void;
}

class ResponseIntercepterDef implements ResponseIntercepter {

    public function new() {
        
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
            default:
        }
    }
}
