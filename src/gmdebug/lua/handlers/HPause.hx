package gmdebug.lua.handlers;

class HPause implements IHandler<PauseRequest> {

    public function new() {

    }
    
    public function handle(pause:PauseRequest):HandlerResponse {
        var rep = req.compose(pause,{});
        rep.send();
        Debugee.startHaltLoop(Pause,Debugee.stackOffset.pause);
        return WAIT;
    }
}