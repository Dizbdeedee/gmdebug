package gmdebug.dap.io;

import gmdebug.Cross;
import sys.FileSystem;
import gmdebug.dap.clients.Client;
import gmdebug.dap.clients.Server;
import gmdebug.dap.clients.BaseConnected;
import gmdebug.dap.clients.ClientStorage;
import haxe.io.Path.join;
import haxe.io.Bytes;
import haxe.Json;
import node.Fs;
import node.Crypto;
import haxe.io.Path as HxPath;
import haxe.io.Path.join;
import js.node.Buffer;
import gmdebug.composer.ComposedEvent;
import gmdebug.PromiseUtil;

using tink.CoreApi;
using Lambda;

enum SlotStatusHandshake {
	UNAVALIABLE;
	START(connect:ConnectionProcess);
	CONNECTED(bc:BaseConnected);
}

enum ConnectionStatusHandshake {
	NOTHING;
	TAKEN;
}

typedef Outtink<T> = Outcome<T, tink.core.Error>;

enum ConnectionProcess {
	START_CONNECT(id:String);
	PIPE_SOCKET_IN_PROGRESS(ps:PipeSocket);
}

enum PProg<T> {
	CONTINUE;
	RESULT(t:T);
}

typedef PromiseProg<T> = Promise<PProg<T>>;

typedef NextConnection = {
	var timeouttime:Float;
	var dataLocations:DataLocations;
	var slots:Array<SlotStatusHandshake>;
	var isServer:Bool;
}

class ClientStorageWithHandshake implements ClientStorage {
	static final SERVER_ID:Int = 0;

	final clients:Array<BaseConnected> = [];

	final clientSlots:Array<SlotStatusHandshake> = [for (_ in 0...MAX_FOLDER_LEN) UNAVALIABLE];

	final serverSlots:Array<SlotStatusHandshake> = [for (_ in 0...MAX_FOLDER_LEN) UNAVALIABLE];

	final readFunc:ReadWithClientID;

	final luaDebug:LuaDebugger;

	var started = false;

	var disconnect = false;

	var gmodIDMap:Map<Int, Client> = [];

	var realIDToSlotID:Map<String, Int> = [];

	var slotIDToRealID:Map<Int, String> = [];

	var queuedServerMessages = [];

	var _uid:String;

	var uid(get, null):String;

	public function new(readFunc:ReadWithClientID, luaDebug:LuaDebugger) {
		this.readFunc = readFunc;
		this.luaDebug = luaDebug;
	}

	// TODO move
	inline function composeMessage(msg:Dynamic):String {
		final json = Json.stringify(msg);
		final len = Bytes.ofString(json)
			.length;
		return 'Content-Length: $len\r\n\r\n$json';
	}

	// rmrf! steamhappy
	function invalidatePreviousConnections(loc:DataLocations) {
		if (Fs.existsSync(loc.pipelocationsfolder)) {
			var manyDataCandidates = Fs.readdirSync(loc.pipelocationsfolder);
			var reg = ~/gmdebug_*/;
			for (dataCandidate in manyDataCandidates) {
				trace(dataCandidate);
			}
			Fs.rmdirSync(loc.pipelocationsfolder, untyped {recursive: true, force: true});
		}
		// if (Fs.existsSync(loc.handshakelocations.folder)) {
		//	Fs.rmdirSync(loc.handshakelocations.folder, untyped {recursive: true, force: true});
		// }
		Fs.mkdirSync(loc.pipelocationsfolder);
		if (!Fs.existsSync(loc.handshakelocations.folder)) {
			Fs.mkdirSync(loc.handshakelocations.folder);
		}
	}

	function get_uid():String {
		if (_uid == null) {
			_uid = Crypto.randomUUID();
		}
		return _uid;
	}

	function getStatusOfConnectingClients(dataLocations:DataLocations):Array<String> {
		var handshakeLocations = dataLocations.handshakelocations;
		if (!Fs.existsSync(handshakeLocations.folder)) {
			Fs.mkdirSync(handshakeLocations.folder);
		}
		var clientsMatched:Array<String> = [];
		var manyPotentialClients = Fs.readdirSync(handshakeLocations.folder);
		var reg = new EReg('${PATH_HANDSHAKE_CLIENT}(.*)\\.dat', ''); // whatever
		for (potentialClient in manyPotentialClients) {
			var anyMatch = reg.match(potentialClient);
			if (anyMatch) {
				var clientID = reg.matched(1); // TODO this will error
				// assume that we will definitely connect... for now
				trace('${HxPath.join
								  ([handshakeLocations.folder,potentialClient]))}');
				if (Fs.existsSync(HxPath.join([handshakeLocations.folder, potentialClient]))) {
					clientsMatched.push(clientID);
				} else {
					trace('Handshake has gone missing! Ignoring');
				}
			}
		}
		return clientsMatched;
	}

	function getLastAvaliableSlot(manySlots:Array<SlotStatusHandshake>):Option<Int> {
		for (i => slot in manySlots) {
			if (slot == UNAVALIABLE) {
				return Some(i);
			}
		}
		return None;
	}

	function storeRealID(id:String, slotID:Int) {
		realIDToSlotID.set(id, slotID);
		slotIDToRealID.set(slotID, id);
	}

	function newServer(pipeSocket:PipeSocket) {
		final clID = SERVER_ID;
		final server = new Server(pipeSocket, clID);
		clients.push(server);
		pipeSocket.assignRead((buf) -> readFunc(buf, clID));
		pipeSocket.beginConnection();
		server.disconnectFuture.handle(() -> {
			luaDebug.sendEvent(new ComposedEvent(thread, {
				reason: Exited,
				threadId: server.clID
			}));
			server.disconnect();
			// clients[clID] = null;
		});
		return server;
	}

	function newClient(pipeSocket:PipeSocket) {
		final clID = clients.length;
		final client = new Client(pipeSocket, clID);
		clients.push(client);
		pipeSocket.assignRead((buf) -> readFunc(buf, clID));
		pipeSocket.beginConnection();
		client.disconnectFuture.handle(() -> {
			luaDebug.sendEvent(new ComposedEvent(thread, {
				reason: Exited,
				threadId: client.clID
			}));
			client.disconnect(); // mm...
			// clients[clID] = null;
		});
		return client;
	}

	function updateOurHandshake(dataLocations:DataLocations) {
		var handshake = dataLocations.handshakelocations;
		{
			var pth = handshake.pre_path_server_handshake + '$uid';
			try {
				Fs.writeFileSync(pth, Std.string(Sys.time()));
			} catch (e) {
				trace('Error writing handshake file');
			}
		}
	}

	function connections(vars:NextConnection):PromiseProg<BaseConnected> {
		var manySlots = vars.slots;
		var timeoutTime = vars.timeouttime;
		var dataLocations = vars.dataLocations;
		var handshakeLocations = dataLocations.handshakelocations;
		var isServer = vars.isServer;
		updateOurHandshake(vars.dataLocations);
		var clientsMatched = getStatusOfConnectingClients(dataLocations);
		if (clientsMatched.length != 0) {
			var clientRealID = clientsMatched.pop();
			var slotID = switch (getLastAvaliableSlot(manySlots)) {
				case None:
					return Promise.reject(new Error("No slots avaliable"));
				case Some(slotID):
					slotID;
			}
			// TODO split out
			{
				var file = handshakeLocations.pre_path_client_handshake + clientRealID + Cross.PATH_DAT_EXT;
				if (Fs.existsSync(file)) {
					try {
						Fs.unlinkSync(file);
						manySlots[slotID] = START(START_CONNECT(clientRealID));
						storeRealID(clientRealID, slotID);
					} catch (e) {
						trace('Error deleting handshake file');
					}
				} else {
					trace('Handshake has gone missing! Ignoring');
				}
			}
		}
		for (i => slot in manySlots) {
			switch (slot) {
				case UNAVALIABLE: // skip
				case START(START_CONNECT(id)):
					var pipeLocations = generatePipeLocationsWithID(dataLocations, id);
					trace(pipeLocations);
					manySlots[i] = START(PIPE_SOCKET_IN_PROGRESS(new PipeSocket(pipeLocations)));
				case START(PIPE_SOCKET_IN_PROGRESS(ps)):
					return ps.aquire()
						.flatMap((result:Outtink<PipeSocket>) -> {
							return
								switch (result) { // TODO (this is a bit of a mess) - copilots words not mine, (but I agree). Robots are objectively correct (in this case.)
								case Success(ps):
									if (isServer) {
										var server = newServer(ps);
										manySlots[i] = CONNECTED(server);
										Promise.resolve(RESULT((server : BaseConnected)));
									} else {
										var client = newClient(ps);
										manySlots[i] = CONNECTED(client);
										Promise.resolve(RESULT((client : BaseConnected)));
									}
								case Failure(err):
									trace("UNABLE TO CONNECT TO CLIENT in connection");
									trace(err);
									manySlots[i] = UNAVALIABLE;
									Promise.resolve(CONTINUE);
							}
						});
				default:
					// skip
			}
		}
		return Promise.resolve(CONTINUE);
	}

	function nextConnectionServer(out:PProg<BaseConnected>, vars:NextConnection):Promise<Server> {
		return switch (out) {
			case RESULT(bc):
				Promise.resolve(cast bc);
			case CONTINUE:
				if (haxe.Timer.stamp() > vars.timeouttime) {
					Promise.reject(new Error("Timeout"));
				} else {
					connections(vars).next(nextConnectionServer.bind(_, vars));
				}
		}
	}

	function continueAquiringServers(dataLocations:DataLocations, timeout:Int):Promise<Server> {
		invalidatePreviousConnections(dataLocations);
		trace("ATTEMPTING SERVER");
		var timeoutTime = haxe.Timer.stamp() + timeout;
		// get potential clients
		var vars = {
			timeouttime: timeoutTime,
			dataLocations: dataLocations,
			slots: serverSlots,
			isServer: true
		};
		return connections(vars).next(nextConnectionServer.bind(_, vars));
	}

	public function attemptServer(serverLoc:String, timeout:Int):Promise<Server> {
		var dataLocations = generateDataLocations(serverLoc);
		return continueAquiringServers(dataLocations, timeout);
	}

	public function getClients():Array<BaseConnected> {
		return clients;
	}

	public function firstClient(clientLoc:String) {
		return null;
	}

	public function attemptClient(clientLoc:String) {
		return null;
	}

	public function firstClientRevised(clientLoc:String) {
		var dataLocations = generateDataLocations(clientLoc);
		invalidatePreviousConnections(dataLocations);
	}

	function aquireClientResult(out:Outtink<PProg<BaseConnected>>):Future<Option<Client>> {
		return switch (out) {
			case Success(RESULT(bc)):
				return Future.sync(Some(cast bc));
			case Success(CONTINUE):
				return Future.sync(None);
			case Failure(err):
				trace("FAILED TO CONNECT TO CLIENT");
				trace(err);
				return Future.sync(None);
		}
	}

	public function attemptClientRevised(clientLoc:String):Future<Option<Client>> {
		var dataLocations = generateDataLocations(clientLoc);
		var vars = {
			timeouttime: null,
			dataLocations: dataLocations,
			slots: clientSlots,
			isServer: false
		};
		return connections(vars).flatMap(aquireClientResult);
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

	public function sendClient(id:Int, msg:Dynamic) {
		if (id == SERVER_ID) {
			throw "Attempt to send to server....";
		}
		clients[id].sendRaw(composeMessage(msg));
	}

	public function sendAll(msg:Dynamic) {
		final comp = composeMessage(msg);
		clients.iter((c) -> c.sendRaw(comp));
	}

	public function sendAny(id:Int, msg:Dynamic) {
		clients[id].sendRaw(composeMessage(msg));
	}

	public function sendAnyRaw(id:Int, str:String) {
		clients[id].sendRaw(str);
	}

	public function getByGmodID(id:Int):Client {
		return gmodIDMap.get(id);
	}

	public function disconnectAll() {
		disconnect = true;
		clients.iter((c) -> c.disconnect());
	}

	function get(id:Int) {
		return clients[id];
	}
}
