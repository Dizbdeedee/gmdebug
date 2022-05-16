package gmdebug.lua.handlers;

typedef InitHStepIn = {
	debugee : Debugee
}

class HStepIn implements IHandler<StepInRequest> {
	
	final debugee:Debugee;

	public function new(initHStepIn:InitHStepIn) {
		debugee = initHStepIn.debugee;
	}

	public function handle(stepInReq:StepInRequest):HandlerResponse {
		debugee.state = STEP(null);
		var rep = stepInReq.compose(stepIn);
		debugee.sendMessage(rep);
		DebugLoop.enableLineStep();
		return CONTINUE;
	}
}
