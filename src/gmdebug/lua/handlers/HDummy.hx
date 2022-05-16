package gmdebug.lua.handlers;

import gmdebug.composer.RequestString;
import gmdebug.composer.ComposedResponse;

typedef HDummyInit = {
	debugee : Debugee
}

class HDummy implements IHandler<Request<Dynamic>> {
	
	final debugee:Debugee;

	public function new(init:HDummyInit) {
		debugee = init.debugee;
	}

	// see ComposeTools.compose
	public function handle(req:Request<Dynamic>):HandlerResponse {
		var response = new ComposedResponse(req, {});
		response.success = true;
		debugee.sendMessage(response);
		return WAIT;
	}
}
