package gmdebug.lua.handlers;

typedef InitHLoadedSources = {
    debugee : Debugee
}

class HLoadedSources implements IHandler<LoadedSourcesRequest> {

    final debugee:Debugee;
    
    public function new(init:InitHLoadedSources) {
        debugee = init.debugee;
    }

    public function handle(load:LoadedSourcesRequest) {
        var resp = load.compose(loadedSources, {sources: []});
		debugee.sendMessage(resp);
		return WAIT;
    }
}