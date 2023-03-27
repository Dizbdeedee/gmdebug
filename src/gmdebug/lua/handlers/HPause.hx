package gmdebug.lua.handlers;

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
		var rep = pauseReq.compose(pause, {});
		debugee.sendMessage(rep);
		debugee.startHaltLoop(Pause,  StackConst.PAUSE);
		return WAIT;
	}
}
