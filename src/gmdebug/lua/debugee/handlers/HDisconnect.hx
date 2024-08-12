package gmdebug.lua.debugee.handlers;

import gmdebug.lua.debugee.handlers.IHandler;

class HDisconnect implements IHandler<DisconnectRequest> {
	public function new() {}

	public function handle(stepIn:DisconnectRequest):HandlerResponse {
		return DISCONNECT;
	}
}
