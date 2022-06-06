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
using tink.CoreApi;

typedef ClientID = Int;

typedef ReadWithClientID = (buf:Buffer,id:Int) -> Void;

enum ConnectionStatus {
	AVALIABLE;
	TAKEN;
	NOT_AVALIABLE;
}

enum SlotStatus {
	TAKEN(ps:PipeSocket);
	AQUIRING(ps:PipeSocket);
	AVALIABLE;
}

final MAX_FOLDER_LEN = 127;
//DebugeeStorage
@:await
class ClientStorage {

	static final SERVER_ID = 0;

	final clients:Array<BaseConnected> = [];

	final clientSlots:Array<SlotStatus> = [for (_ in 0...MAX_FOLDER_LEN) AVALIABLE];

	final serverSlots:Array<SlotStatus> = [for (_ in 0...MAX_FOLDER_LEN) AVALIABLE];
	
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
		} else if (FileSystem.exists(join([loc,PATH_CONNECTION_IN_PROGRESS])) || FileSystem.exists(join([loc,PATH_CONNECTION_AQUIRED]))) {
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
		for (i in 1...MAX_FOLDER_LEN) {
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
	
	function getFreeFolderS(loc:String):Array<String> {
		final results = [];
		for (i in 0...MAX_FOLDER_LEN) {
			var append = '$i';
			if (i == 0) append = "";
			switch (status(join([loc,PATH_DATA,'$PATH_FOLDER$append']))) {
				case AVALIABLE:
					results.push(join([loc,PATH_DATA,'$PATH_FOLDER$append']));
				case NOT_AVALIABLE:
					break;
				case TAKEN:
					results.push(null);
			}
		}
		return results;
	}
	
	function findAquiresInProgress(loc:String,slots:Array<SlotStatus>) {
		final folders = getFreeFolderS(loc);
		final aqs:Array<Promise<PipeSocket>> = [];
		for (i in 0...slots.length) {
			switch ([slots[i],folders[i]]) {
				case [AVALIABLE,x] if (x != null):
					slots[i] = AQUIRING(new PipeSocket(generatePipeLocations(folders[i])));
				case [AQUIRING(ps),_]:
					aqs.push(ps.aquire());
				default:
			}
		}
		return aqs;
	}

	public function continueAquires(locs:String):Future<Array<Client>> {
		return Future.irreversible((done) -> {
			final pms = findAquiresInProgress(locs,clientSlots);
			Future.inSequence(pms).handle(results -> {
				var newClients = [];
				for (result in results) {
					switch (result) {
						case Success(socket):
							final clID = clients.length; 
							final client = new Client(socket,clID);
							clients.push(client);
							socket.assignRead((buf) -> readFunc(buf,clID));
							socket.beginConnection();
							newClients.push(client);
						case Failure(err):
							trace(err);
					}
				}
				done(newClients);
			});
		});
	}

	public function continueAquireServer(serverLoc:String):Promise<Server> {
		return Future.irreversible((done) -> {
			final pms = findAquiresInProgress(serverLoc,serverSlots);
			Future.inSequence(pms).handle(results -> {
				var server = null;
				for (result in results) {
					switch (result) {
						case Success(socket):
							final clID = SERVER_ID; 
							final client = new Server(socket,clID);
							clients.push(client);
							socket.assignRead((buf) -> readFunc(buf,clID));
							socket.beginConnection();
							server = client;
							break;
						case Failure(err):
							// trace(err);
					}
				}
				trace('The thing $server');
				if (server != null) done(Success(server));
				done(Failure(new Error("Not happenin now")));
				
			});
			
		});
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
