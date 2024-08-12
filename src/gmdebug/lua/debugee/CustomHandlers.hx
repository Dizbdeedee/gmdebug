package gmdebug.lua.debugee;

import gmdebug.lua.debugee.util.Util.isLan;
import gmod.libs.GameLib;
import gmdebug.protocol.ext.messages.GmDebugMessage;
import gmdebug.protocol.ext.messages.GmDebugInitialInfo;
import gmdebug.protocol.ext.messages.GMClientID;
import gmod.Gmod;

class CustomHandlers {
	public function new() {}

	public function handle(x:GmDebugMessage<Dynamic>):CustomHandlersResponse {
		return switch (x.msg) {
			case clientID:
				h_clientID(cast x);
			case intialInfo:
				h_initalInfo(cast x);
			case playerAdded | playerRemoved | serverInfo:
				throw "Invalid customhandlers message";
			default:
				throw "Invalid customhandlers message";
		}
	}

	function h_clientID(x:GmDebugMessage<GMClientID>) {
		trace('recieved id ${x.body.id}');
		return CLIENT_ID(x.body.id);
	}

	function h_initalInfo(x:GmDebugMessage<GmDebugInitialInfo>) {
		return if (x.body.dapMode == Launch) { // previously send IP
			INITIAL_INFO(x.body.location, Launch);
		} else {
			INITIAL_INFO(x.body.location, Attach);
		}
	}
}

enum CustomHandlersResponse {
	CLIENT_ID(id:Int);
	INITIAL_INFO(dest:String, dapMode:DapModeStr);
}
