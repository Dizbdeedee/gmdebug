package gmdebug.dap.clients;

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

using Lambda;

typedef ClientID = Int;

typedef ReadWithClientID = (buf:Buffer,id:Int) -> Void;

enum ConnectionStatus {
	AVALIABLE;
	TAKEN;
	NOT_AVALIABLE;
}
//DebugeeStorage
@:await
class ClientStorage {

	static final SERVER_ID = 0;

	final clients:Array<BaseConnected> = [];
	
	final readFunc:ReadWithClientID;

	var disconnect = false;

	var gmodIDMap:Map<Int,Client> = [];

	var queuedServerMessages = [];

	public function new(readFunc:ReadWithClientID) {
		this.readFunc = readFunc;
	}

	//TODO move
	inline function composeMessage(msg:Dynamic):String {
		final json = Json.stringify(msg);
		final len = Bytes.ofString(json).length;
		return 'Content-Length: $len\r\n\r\n$json';
	}

	function status(loc:String):ConnectionStatus {
		return if (!FileSystem.exists(loc)) {
			NOT_AVALIABLE;
		} else if (FileSystem.exists(join([loc,PATH_AQUIRED]))) {
			TAKEN;
		} else {
			AVALIABLE;
		}
	}

	function getFreeFolder(loc:String):String {
		switch (status(join([loc,PATH_DATA,PATH_FOLDER]))) {
			case AVALIABLE:
				return join([loc,PATH_DATA,PATH_FOLDER]);
			case NOT_AVALIABLE:
				throw new Error("No free connections");
			case TAKEN:
		}
		for (i in 1...127) {
			switch (status(join([loc,PATH_DATA,'$PATH_FOLDER$i']))) {
				case AVALIABLE:
					return join([loc,PATH_DATA,'$PATH_FOLDER$i']);
				case NOT_AVALIABLE:
					throw new Error('No free connections $i');
				case TAKEN:
			}
		}
		throw new Error('Exhasted all possible connections');
	}

	function generateSocketLocations(chosenFolder:String):PipeSocketLocations {
		return {
			debugee_output : join([chosenFolder,PATH_OUTPUT]),
			debugee_input : join([chosenFolder,PATH_INPUT]),
			ready : join([chosenFolder,PATH_READY]),
			client_ready : join([chosenFolder,PATH_CLIENT_PATH_READY]),
			folder : chosenFolder,
			aquired : join([chosenFolder,PATH_AQUIRED])
		};
	}

	@:async function makePipeSocket(loc:String,id:Int) {
		final chosenFolder = getFreeFolder(loc);
		final ps = new PipeSocket(generateSocketLocations(chosenFolder),
			(buf:Buffer) -> readFunc(buf,id)
		);
		@:await ps.aquire().eager();
		trace("mega aquired");
		return ps;
	}


	@:async public function newClient(clientLoc:String) {
		final clID = clients.length; 
		final pipesocket = @:await makePipeSocket(clientLoc,clID);
		final client = new Client(pipesocket,clID);
		clients.push(client);
		trace("client created");
		// gmodIDMap.set(gmodID,client);
		return client;
	}

	@:async public function newServer(serverLoc:String) {
		final clID = SERVER_ID;
		final pipesocket = @:await makePipeSocket(serverLoc,clID);
		trace("Server created");
		final server = new Server(pipesocket, clID);
		clients[SERVER_ID] = server;
		return server;
	}

	function get(id:Int) {
		return clients[id];
	}

	public function sendServer(msg:Dynamic) {
		if (clients[SERVER_ID] == null) {
			queuedServerMessages.push(composeMessage(msg));
		} else {
			for (i in queuedServerMessages) {
				clients[SERVER_ID].sendRaw(i);
			}
			queuedServerMessages = [];
			clients[SERVER_ID].sendRaw(composeMessage(msg));
		}
	}

	public function sendClient(id:Int,msg:Dynamic) {
		if (id == SERVER_ID) {
			throw "Attempt to send to server....";
		}
		clients[id].sendRaw(composeMessage(msg));
	}

	public function getClients():Array<Client> {
		return cast clients.slice(1);
	}

	public function sendAll(msg:Dynamic) {
		final comp = composeMessage(msg);
		clients.iter((c) -> c.sendRaw(comp));
	}

	public function sendAny(id:Int,msg:Dynamic) {
		clients[id].sendRaw(composeMessage(msg));
	}

	public function sendAnyRaw(id:Int,str:String) {
		clients[id].sendRaw(str);
	}

	public function getByGmodID(id:Int) {
		return gmodIDMap.get(id);  
	}

	public function disconnectAll() {
		disconnect = true;
		clients.iter((c) -> c.disconnect());
	}
}
