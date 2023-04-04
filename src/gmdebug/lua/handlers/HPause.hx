package gmdebug.lua.handlers;

import gmdebug.lua.debugcontext.DebugContext;
import gmdebug.lua.handlers.IHandler.HandlerResponse;

typedef InitHPause = { 
	debugee : Debugee
}

class HPause implements IHandler<PauseRequest> {
	final debugee:Debugee;
	public function new(init:InitHPause) {
		debugee = init.debugee;
	}

	public function handle(pauseReq:PauseRequest):HandlerResponse {
		// var rep = pauseReq.compose(pause, {});
		// debugee.sendMessage(rep);
		// DebugContext.enterDebugContext();
		// DebugContext.debugContext({debugee.startHaltLoop(Pause);});
		// DebugContext.exitDebugContext();
		return PAUSE(pauseReq);
	}
}
