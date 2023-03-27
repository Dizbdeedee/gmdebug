package gmdebug.lua.handlers;

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
		var tarheight = debugee.stepHeight - 1;
		trace('stepOut ${tarheight < StackConst.MIN_HEIGHT} : $tarheight ${StackConst.MIN_HEIGHT}');
		if (tarheight <= StackConst.MIN_HEIGHT) {
			final info = DebugLib.getinfo(debugee.baseDepth.unsafe() + 1, "fLSl");
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
			debugee.state = OUT(func, lowest - 1,tarheight + 1); //lowest - 1, as call hook starts on first line
		} else {
			debugee.state = STEP(tarheight);
		}
		DebugLoop.enableLineStep();
		final stepoutResp = stepOutReq.compose(stepOut);
		debugee.sendMessage(stepoutResp);
		return CONTINUE;
	}
}
