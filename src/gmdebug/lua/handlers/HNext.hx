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
		var tarheight = debugee.stepHeight;
		trace('targeting $tarheight - (${debugee.stackHeight} ${ StackConst.STEP})');

		debugee.state = STEP(tarheight);
		debugee.sendMessage(resp);
		DebugLoop.enableLineStep();
		return CONTINUE;
	}
}
