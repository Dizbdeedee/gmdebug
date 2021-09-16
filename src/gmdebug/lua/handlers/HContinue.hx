package gmdebug.lua.handlers;
import gmdebug.lua.managers.VariableManager;

typedef InitHContinue = {
	vm : VariableManager,
	debugee : Debugee
}
class HContinue implements IHandler<ContinueRequest> {

	final variableManager:VariableManager;

	final debugee:Debugee;

	public function new(init:InitHContinue) {
		variableManager = init.vm;
		debugee = init.debugee;
	}


	public function handle(contReq:ContinueRequest):HandlerResponse {
		var resp = contReq.compose(_continue, {allThreadsContinued: false});
		debugee.sendMessage(resp);
		variableManager.resetVariables();
		return CONTINUE;
	}
}
