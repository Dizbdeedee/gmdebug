package gmdebug.composer;

#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end

#if lua
import gmdebug.lua.Debugee;
#end
import haxe.Json;

class ComposedProtocolMessage {

	public var seq:Int = 0;

	public var type:MessageType;

	public function new(_type:MessageType) {
		type = _type;
	}

	#if lua
	public inline function send() {

		var js = Json.stringify(this);
		Debugee.writeJson(js);
	}

	public inline function sendtink(x:String) {
		Debugee.writeJson(x);
	}
	#end
}
