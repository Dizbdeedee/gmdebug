package gmdebug.lua.handlers;

typedef InitHSetExceptionBreakpoints = {
	debugee : Debugee
}

class HSetExceptionBreakpoints implements IHandler<SetExceptionBreakpointsRequest> {

	final debugee:Debugee;

	public function new(init:InitHSetExceptionBreakpoints) {
		debugee = init.debugee;
	}

	public function handle(x:SetExceptionBreakpointsRequest):HandlerResponse {
		var resp = x.compose(setExceptionBreakpoints);
		var gamemodeSet = false;
		var entitiesSet = false;
		for (filter in x.arguments.unsafe().filters) {
			switch (filter) {
				case gamemode:
					// Exceptions.hookGamemodeHooks();
					gamemodeSet = true;
				case entities:
					// Exceptions.hookEntityHooks();
					entitiesSet = true;
			}
		}
		if (!gamemodeSet)
			// Exceptions.unhookGamemodeHooks();
		if (!entitiesSet)
			// Exceptions.unhookEntityHooks();
		debugee.sendMessage(resp);
		return WAIT;
	}
}
