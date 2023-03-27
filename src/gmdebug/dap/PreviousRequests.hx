package gmdebug.dap;

import gmdebug.composer.RequestString.AnyRequest;

#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end
class PreviousRequests {

    var prevRequestMap:Map<String,Request<Dynamic>> = [];

    public function new() {}
    
    public function update(req:Request<Dynamic>) {
        prevRequestMap.set(req.command,req);
    }

    public function get(command:AnyRequest):Null<Request<Dynamic>> {
        return prevRequestMap.get(command);
    }

}