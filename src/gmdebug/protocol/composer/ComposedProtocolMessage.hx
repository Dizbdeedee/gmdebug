package gmdebug.protocol.composer;

#if lua
import gmdebug.lua.debugee.Debugee;
#end
import haxe.Json;

class ComposedProtocolMessage {
	public var seq:Int = 0;

	public var type:MessageType;

	public function new(_type:MessageType) {
		type = _type;
	}

	#if lua
	public inline function json() {
		return Json.stringify(this);
	}
	#end
}
