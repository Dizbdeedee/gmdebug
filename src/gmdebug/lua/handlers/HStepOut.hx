package gmdebug.lua.handlers;

import gmdebug.lua.debugcontext.DebugContext;
import gmod.libs.DebugLib;

using Lambda;

typedef InitHStepOut = {
	debugee : Debugee
}
class HStepOut implements IHandler<StepOutRequest> {
	
	final debugee:Debugee;
	
	public function new(initHStepOut:InitHStepOut) {
		debugee = initHStepOut.debugee;
	}

	public function handle(stepOutReq:StepOutRequest):HandlerResponse {
		// var tarheight = debugee.stepHeight - 1;
		// trace('stepOut ${tarheight < StackConst.MIN_HEIGHT} : $tarheight ${StackConst.MIN_HEIGHT}');
		trace('Actual Height: ${debugee.stackHeight} ContextHeight: ${DebugContext.getHeight()}');

		if (debugee.stackHeight - DebugContext.getHeight() <= 0) {
			trace("Out");
			final info = DebugLib.getinfo(DebugContext.getHeight(), "fLSl");
			final func = info.func;
			trace('${info.source}');
            final activeLines = info.activelines;
			final lowest = activeLines.keys().fold((line, res) -> {
				return if (line < res) {
					line;
				} else {
					res;
				}
			}, cast Math.POSITIVE_INFINITY);
			trace('lowest $lowest');
			debugee.state = OUT(func, lowest - 1,DebugContext.getHeight());
		} else {
			trace("Not out");
			debugee.state = STEP(DebugContext.getHeight() - 1);
		}
		DebugLoop.enableLineStep();
		final stepoutResp = stepOutReq.compose(stepOut);
		debugee.sendMessage(stepoutResp);
		return CONTINUE;
	}
}
