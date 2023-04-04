package gmdebug.lua.handlers;

import gmdebug.lua.debugcontext.DebugContext;


typedef InitHNext = {
	debugee : Debugee
}
class HNext implements IHandler<NextRequest> {
	
	final debugee:Debugee;
	
	public function new(init:InitHNext) {
		debugee = init.debugee;
	}

	public function handle(nextReq:NextRequest):HandlerResponse {
		var offsetHeight = DebugContext.getHeight();
		DebugContext.markNotReport();
		var resp = nextReq.compose(next);
		debugee.state = STEP(offsetHeight);
		debugee.sendMessage(resp);
		DebugLoop.enableLineStep();
		DebugContext.markReport();
		return CONTINUE;
	}
}
