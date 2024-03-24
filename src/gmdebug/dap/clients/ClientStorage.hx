package gmdebug.dap.clients;

import haxe.Timer;
import tink.core.Callback.SimpleLink;
import gmdebug.composer.ComposedEvent;
import gmdebug.dap.PipeSocket;
import tink.core.Error;
import gmdebug.dap.PipeSocket.PipeSocketLocations;
import haxe.io.Bytes;
import haxe.Json;
import js.node.Fs;
import sys.FileSystem;
import haxe.io.Path as HxPath;
import haxe.io.Path.join;
import js.node.Buffer;
import gmdebug.Cross;
import gmdebug.PromiseUtil;

using Lambda;
using tink.CoreApi;

interface ClientStorage {
	function attemptServer(serverLoc:String, timeout:Int):Promise<Server>;
	function firstClient(clientLoc:String):Void;
	function firstClientRevised(clientLoc:String):Void;
	function attemptClient(clientLoc:String):Future<Array<Client>>;
	function attemptClientRevised(clientLoc:String):Future<Option<Client>>;
	function sendServer(msg:Dynamic):Void;
	function sendClient(id:Int, msg:Dynamic):Void;
	function sendAll(msg:Dynamic):Void;
	function sendAny(id:Int, msg:Dynamic):Void;
	function sendAnyRaw(id:Int, str:String):Void;
	function getByGmodID(id:Int):Client;
	function disconnectAll():Void;
	function getClients():Array<BaseConnected>;
}

// old client storage is deth

typedef ClientID = Int;
typedef ReadWithClientID = (buf:Buffer, id:Int) -> Void;

enum ConnectionStatus {
	AVALIABLE;
	STRANGE;
	TAKEN;
	NOTHING;
}

enum SlotStatus {
	TAKEN(ps:PipeSocket);
	AQUIRING(fut:Promise<PipeSocket>);
	UNKNOWN;
	AVALIABLE;
}

final MAX_FOLDER_LEN = 127;
