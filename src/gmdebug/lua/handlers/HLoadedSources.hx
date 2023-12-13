package gmdebug.lua.handlers;

import gmdebug.lua.SourceContainer;

typedef InitHLoadedSources = {
	debugee:Debugee,
	sc:SourceContainer
}

class HLoadedSources implements IHandler<LoadedSourcesRequest> {
	final debugee:Debugee;

	final sc:SourceContainer;

	public function new(init:InitHLoadedSources) {
		debugee = init.debugee;
		sc = init.sc;
	}

	public function handle(load:LoadedSourcesRequest) {
		final sourceArr = [];
		for (si in sc.sourceCache) {
			final result = sc.infoToSource(si);
			if (result != null) {
				sourceArr.push(result);
			}
		}
		var resp = load.compose(loadedSources, {
			sources: sourceArr
		});
		debugee.sendMessage(resp);
		return WAIT;
	}
}
