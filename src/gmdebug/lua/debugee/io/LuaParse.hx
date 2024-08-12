package gmdebug.lua.debugee.io;

import gmdebug.protocol.ext.ProtocolUtil.readHeader;
import haxe.Json;
import gmdebug.protocol.ext.ProtocolUtil.MessageResult;
import haxe.io.Input;


class LuaParse {

	
	public static function recvMessage(x:Input):MessageResult {
		var len = readHeader(x);
		if (len == null) {
			return ACK;
		}
		var dyn = x.readString(len, UTF8); // argh
		#if (lua && jsonDump)
		FileLib.Append(HxPath.join([PATH_FOLDER, "log.txt"]), dyn);
		#end
		return MESSAGE(Json.parse(dyn)); //REPLACE WITH LUA UTIL JSON
	}
}