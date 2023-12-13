package gmdebug.dap;

function tracev(dyn:Dynamic, ?posInfo:haxe.PosInfos) {
	#if verbose
	haxe.Log.trace(dyn, posInfo);
	#end
}
