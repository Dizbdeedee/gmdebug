package gmdebug.lua.handlers;

typedef InitHLoadedSources = {
    debugee : Debugee,
    sourceCache: SourceContainer
}

class HLoadedSources implements IHandler<LoadedSourcesRequest> {

    final debugee:Debugee;

    public function new(init:InitHLoadedSources) {
        debugee = init.debugee;
    }

    public function handle(load:LoadedSourcesRequest) {
        for (si in
        var resp = load.compose(loadedSources, {
            sources: []
        });
        debugee.sendMessage(resp);
        return WAIT;
    }
}