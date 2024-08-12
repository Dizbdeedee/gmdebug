package gmdebug.lua.debugee.handlers;

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
