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
	AQUIRING(fut:Promise<PipeSocket>);
	AVALIABLE;
	NOT_AVALIABLE;
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

	final luaDebug:LuaDebugger;
	
	var disconnect = false;

	var gmodIDMap:Map<Int,Client> = [];

	var queuedServerMessages = [];

	public function new(readFunc:ReadWithClientID,luaDebug:LuaDebugger) {
		this.readFunc = readFunc;
		this.luaDebug = luaDebug;
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

	function getStatusFolders(loc:String):Array<ConnectionStatus> {
		final results = [];
		for (i in 0...MAX_FOLDER_LEN) {
			var folderLoc = join([loc,PATH_FOLDER,Std.string(i)]);
			results.push(status(folderLoc));
		}
		return results;
	}

	function invalidatePreviousConnections(locs:String,slots:Array<SlotStatus>) {
		var statuses = getStatusFolders(locs);
		for (i in 0...slots.length) {
			switch (statuses[i]) {
				case AVALIABLE | TAKEN:
					slots[i] = NOT_AVALIABLE;
				default:
			}
		}
	}

	public function lookForConnections(locs:String,slots:Array<SlotStatus>):Future<PipeSocket> {
		return new Future(function (success) {
			var outcomes:Array<CallbackLink> = [];
			var watcher = Fs.watch(locs,{persistent: false},function (_, _) {
				var statuses = getStatusFolders(locs);
				for (i in 0...slots.length) {
					switch [slots[i],statuses[i]] {
						case [AVALIABLE, AVALIABLE]:
							var sock = new PipeSocket(generatePipeLocations(join([locs,PATH_FOLDER,Std.string(i)])));
							var sockOutcome = sock.aquire().handle(function (outcome) {
								switch (outcome) {
									case Success(data):
										success(data);
									default:
								}
							});
							outcomes.push(sockOutcome);
						default:
					}
				}
			});
			return () -> {
				watcher.close();
				outcomes.iter((l) -> l.cancel());
			};
		});
	}

	public function continueAquireServer(serverLoc:String,timeout:Int):Promise<Server> {
		return new Promise(function (success,failure) {
			Timer.delay(() -> {
				failure(new Error("ClientStorage/continueAquireServer: timeout"));
			},timeout);
			var connHandler = lookForConnections(serverLoc,serverSlots).handle(function (pipesocket) {
				final clID = SERVER_ID; 
				final server = new Server(pipesocket,clID);
				clients.push(server);
				pipesocket.assignRead((buf) -> readFunc(buf,clID));
				pipesocket.beginConnection();
				server.disconnectFuture.handle(() -> {
					luaDebug.sendEvent(new ComposedEvent(thread,{
						reason: Exited,
						threadId: server.clID
					}));
					server.disconnect();
					clients[clID] = null;
				});
				success(server);
			});
			return () -> {
				connHandler.cancel();
			};
		});
	}

	// public function continueAquireServer(serverLoc:String):Promise<Server> {
	// 	return Future.irreversible((done) -> {
	// 		final pms = findAquiresInProgress(serverLoc,serverSlots);
	// 		Future.inSequence(pms).handle(results -> {
	// 			var server = null;
	// 			for (result in results) {
	// 				switch (result) {
	// 					case Success(socket):
	// 						final clID = SERVER_ID; 
	// 						final client = new Server(socket,clID);
	// 						clients.push(client);
	// 						socket.assignRead((buf) -> readFunc(buf,clID));
	// 						socket.beginConnection();
	// 						client.disconnectFuture.handle(() -> {
	// 							luaDebug.sendEvent(new ComposedEvent(thread,{
	// 								reason: Exited,
	// 								threadId: client.clID
	// 							}));
	// 							client.disconnect();
	// 							clients[clID] = null;
	// 						});
	// 						server = client;
	// 						break;
	// 					case Failure(err):
	// 						// trace(err);
	// 				}
	// 			}
	// 			if (server != null) done(Success(server));
	// 			done(Failure(new Error("Not happenin now")));
				
	// 		});
			
	// 	});
	// }

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
