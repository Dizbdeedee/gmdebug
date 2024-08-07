package gmdebug.protocol.ext;

import haxe.io.Input;
import haxe.Json;

@:nullSafety(Off)
function readHeader(x:Input) {
	var raw_content = x.readLine();
	var skip = 0;
	var onlySkipped = true;
	for (i in 0...raw_content.length) {
		if (raw_content.charCodeAt(i) == 4) {
			skip++;
		} else {
			onlySkipped = false;
			break;
		}
	}
	#if lua
	if (onlySkipped) { // only happens on lua
		return null;
	}
	#end
	if (skip > 0) {
		// skipped x
		raw_content = raw_content.substr(skip);
	}
	var content_length = Std.parseInt(@:nullSafety(Off) raw_content.substr(15));
	x.readLine();
	#if (lua && jsonDump)
	FileLib.Append(HxPath.join([PATH_FOLDER, "log.txt"]), raw_content + garbage + ';$content_length;');
	#end
	return content_length;
}

@:nullSafety(Off)
function recvMessage(x:Input):MessageResult {
	var len = readHeader(x);
	if (len == null) {
		return ACK;
	}
	var dyn = x.readString(len, UTF8); // argh
	#if (lua && jsonDump)
	FileLib.Append(HxPath.join([PATH_FOLDER, "log.txt"]), dyn);
	#end
	return MESSAGE(Json.parse(dyn));
}

enum MessageResult {
	ACK;
	MESSAGE(x:Dynamic);
}
