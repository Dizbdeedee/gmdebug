package gmdebug;


import haxe.display.Protocol.InitializeParams;
import haxe.io.BytesData;
import haxe.io.Bytes;
import tink.CoreApi.Ref;
#if lua
import gmdebug.lib.lua.Protocol.ProtocolMessage;
import gmod.libs.FileLib;
#elseif js
import vscode.debugProtocol.DebugProtocol.ProtocolMessage;
#end
import gmdebug.VariableReference;
import haxe.Json;
import haxe.io.Input;
import haxe.io.Path as HxPath;

final PATH_FOLDER = "gmdebug";

final PATH_CLIENT_READY = "client_waiting.dat";

final PATH_CLIENT_ACK = "client_ack.dat";

final PATH_INPUT = "in.dat";

final PATH_OUTPUT = "out.dat";

final PATH_CONNECTION = "connect.dat";

final PATH_PIPES_READY = "pipes_ready.dat";

final PATH_CONNECTION_IN_PROGRESS = "connection_progress.dat";

final PATH_CONNECTION_AQUIRED = "connection_aquired.dat";

final PATH_DATA = "data";

final PATH_ADDONS = "addons";

final JIT = HxPath.join([PATH_FOLDER, "jitchoice.txt"]);

final OUTPUT_INTERCEPTED = "[lua_debug] ";

typedef PipeLocations = {
	folder : String,
	client_ready : String,
	connect : String,
	pipes_ready : String,
	input : String,
	output : String,
	client_ack : String,
	connection_in_progress : String,
	connection_aquired : String
}

function generatePipeLocations(folder:String) {
	return {
		folder : folder,
		client_ready: HxPath.join([folder,PATH_CLIENT_READY]),
		output: HxPath.join([folder,PATH_OUTPUT]),
		input: HxPath.join([folder,PATH_INPUT]),
		pipes_ready: HxPath.join([folder,PATH_PIPES_READY]),
		client_ack : HxPath.join([folder,PATH_CLIENT_ACK]),
		connect: HxPath.join([folder,PATH_CONNECTION]),
		connection_in_progress: HxPath.join([folder,PATH_CONNECTION_IN_PROGRESS]),
		connection_aquired: HxPath.join([folder,PATH_CONNECTION_AQUIRED])
	}
}

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
	FileLib.Append(HxPath.join([PATH_FOLDER,"log.txt"]),raw_content + garbage + ';$content_length;');
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
	FileLib.Append(HxPath.join([PATH_FOLDER,"log.txt"]),dyn);
	#end
	return MESSAGE(Json.parse(dyn));
}


enum CommMethod {
	Pipe;
	Socket;
}

enum MessageResult {
	ACK;
	MESSAGE(x:Dynamic);
}

enum abstract ExceptionBreakpointFilters(String) to String {
	// var all
	var gamemode;
	var entities;
}
