package gmdebug.lua.handlers;

#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end
interface IHandler<T:Request<Dynamic>> {
	function handle(req:T):HandlerResponse;
}

enum HandlerResponse {
	WAIT;
	CONTINUE;
	DISCONNECT;
	PAUSE(pauseReq:PauseRequest);
	CONFIG_DONE;
}
