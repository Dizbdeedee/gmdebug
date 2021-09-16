package gmdebug.lua.handlers;

import gmdebug.lua.managers.BreakpointManager;
import gmdebug.lib.lua.Protocol;

typedef InitHSetBreakpoints = {
    bm : BreakpointManager,
    debugee : Debugee
}

class HSetBreakpoints implements IHandler<SetBreakpointsRequest> {

    final bm:BreakpointManager;

    final debugee:Debugee;

    public function new(init:InitHSetBreakpoints) {
        bm = init.bm;
        debugee = init.debugee;

    }

    public function handle(req:SetBreakpointsRequest):HandlerResponse {
        final args = req.arguments.unsafe();
        final bpResponse:Array<Breakpoint> = [];
        bm.clearBreakpoints(args.source.path);
		if (args.breakpoints != null) {
			for (bp in args.breakpoints) {
                final breakPoint = bm.newBreakpoint(args.source,bp);
                bpResponse.push({
                    line : breakPoint.line,
                    message : breakPoint.message,
                    verified : breakPoint.verified
                });
            }
		}
		var resp = req.compose(setBreakpoints, {breakpoints: bpResponse});
		final json = tink.Json.stringify((cast resp : SetBreakpointsResponse)); // in pratical terms they're the same
		debugee.send(json);
		return WAIT;
	}
}