package gmdebug.lua.handlers;


typedef InitHNext = {
	debugee : Debugee
}
class HNext implements IHandler<NextRequest> {
	
	final debugee:Debugee;
	
	public function new(init:InitHNext) {
		debugee = init.debugee;
	}

	public function handle(nextReq:NextRequest):HandlerResponse {
		var resp = nextReq.compose(next);
		debugee.state = STEP(StackHeightCounter.getRSH());
		debugee.sendMessage(resp);
		DebugLoop.enableLineStep();
		return CONTINUE;
	}
}
