package gmdebug.lua;

import gmdebug.lua.util.Util.isLan;
import gmdebug.composer.*;
import gmod.libs.GameLib;
import gmdebug.GmDebugMessage;
import gmod.Gmod;


typedef InitCustomHandlers = {
	debugee : Debugee
}
class CustomHandlers {

	final debugee:Debugee;

	public function new(initCustomHandlers:InitCustomHandlers) {
		debugee = initCustomHandlers.debugee;
	}

	public function handle(x:GmDebugMessage<Dynamic>) {
		switch (x.msg) {
			case clientID:
				h_clientID(cast x);
			case intialInfo:
				h_initalInfo(cast x);
			case playerAdded | playerRemoved | serverInfo:
				throw "dur";
		}
	}

	function h_clientID(x:GmDebugMessage<GMClientID>) {
		trace('recieved id ${x.body.id}');
		debugee.clientID = x.body.id;
	}

	function h_initalInfo(x:GmDebugMessage<GmDebugIntialInfo>) {
		debugee.dest = x.body.location;
		if (x.body.dapMode == Launch) {
			#if server
			debugee.sendMessage(new ComposedGmDebugMessage(serverInfo, {
				ip: GameLib.GetIPAddress(),
				isLan: isLan()
			}));
			#end
			debugee.dapMode = Launch;
		} else {
			debugee.dapMode = Attach;
		}
	}
}
