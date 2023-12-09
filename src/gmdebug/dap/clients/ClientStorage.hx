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
    function attemptServer(serverLoc:String,timeout:Int):Promise<Server>;
    function firstClient(clientLoc:String):Void;
    function attemptClient(clientLoc:String):Future<Array<Client>>;
    function sendServer(msg:Dynamic):Void;
    function sendClient(id:Int,msg:Dynamic):Void;
    function sendAll(msg:Dynamic):Void;
    function sendAny(id:Int,msg:Dynamic):Void;
    function sendAnyRaw(id:Int,str:String):Void;
    function getByGmodID(id:Int):Client;
    function disconnectAll():Void;
    function getClients():Array<BaseConnected>;
}

@:await
class ClientStorageDef implements ClientStorage {

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

    function connectionStatus(connectionLoc:String):ConnectionStatus {
        return if (!FileSystem.exists(connectionLoc)) {
            // trace('status $connectionLoc Nothing');
            NOTHING;
        } else if (FileSystem.exists(join([connectionLoc,PATH_CONNECTION_IN_PROGRESS]))
            || FileSystem.exists(join([connectionLoc,PATH_CONNECTION_AQUIRED]))
            || FileSystem.exists(join([connectionLoc,PATH_CLIENT_ACK]))
            || FileSystem.exists(join([connectionLoc,PATH_INPUT]))) {
            trace('status $connectionLoc Taken');
            TAKEN;
        } else if (FileSystem.exists(join([connectionLoc,PATH_CLIENT_READY]))) {
            trace('status $connectionLoc AVALIABLE');
            AVALIABLE;
        } else {
            trace('status $connectionLoc Strange');
            STRANGE;
        }
    }

    function gmodLocToSlotLoc(gmodLoc:String) {
        return join([gmodLoc,PATH_DATA]);
    }

    function getConnectionLocForSlot(slotLocation:String,i:Int) {
        return join([slotLocation,PATH_FOLDER + Std.string(i)]);
    }

    function getStatusFolders(slotLocation:String):Array<ConnectionStatus> {
        final results = [];
        for (i in 0...MAX_FOLDER_LEN) {
            var connectionLoc = getConnectionLocForSlot(slotLocation,i);
            results.push(connectionStatus(connectionLoc));
        }
        return results;
    }

    function invalidatePreviousConnections(locs:String,slots:Array<SlotStatus>) {
        var statuses = getStatusFolders(locs);
        for (i in 0...slots.length) {
            switch (statuses[i]) {
                case TAKEN | STRANGE | AVALIABLE: //hmm...
                    trace('INVALIDATING $i');
                    slots[i] = UNKNOWN;
                    trace('APPLE $clientSlots');
                case NOTHING:
                    slots[i] = AVALIABLE;
                default:
            }
        }
    }

    function cleanupConnections(slotLocation:String,slots:Array<SlotStatus>) {
        for (slotID => slot in slots) {
            if (slot == UNKNOWN) {
                var connectionLoc = getConnectionLocForSlot(slotLocation,slotID);
                if (node.Fs.existsSync(connectionLoc)) {
                    node.Fs.rmdirSync(connectionLoc,untyped {recursive: true, force: true});
                }
                slot = AVALIABLE;
            }
        }
    }


    function connectionProcess(slotLocation:String,slots:Array<SlotStatus>):FutureArray<Outcome<PipeSocket,Error>> {
        var statuses = getStatusFolders(slotLocation);
        var sockPromises = new FutureArray();
        cleanupConnections(slotLocation,slots);
        for (i in 0...slots.length) {
            switch [slots[i],statuses[i]] {
                case [AVALIABLE, AVALIABLE]:
                    var connectionLoc = getConnectionLocForSlot(slotLocation,i);
                    var sock = new PipeSocket(generatePipeLocations(connectionLoc));
                    sockPromises.add(sock.aquire());
                default:
            }
        }
        return sockPromises;
    }

    function aquireClients(slotLocation:String,slots:Array<SlotStatus>):Future<Array<Client>> {
        return connectionProcess(slotLocation,slots).inSequence().map((clientOutcomesArr) -> {
            var clientsAquired = [];
            for (clientOut in clientOutcomesArr) {
                switch (clientOut) {
                    case Success(ps):
                        clientsAquired.push(newClient(ps));
                    case Failure(err):
                        trace(err.message);
                }
            }
            return clientsAquired;
        });
    }

    function newClient(pipeSocket:PipeSocket) {
        final clID = clients.length;
        final client = new Client(pipeSocket,clID);
        clients.push(client);
        pipeSocket.assignRead((buf) -> readFunc(buf,clID));
        pipeSocket.beginConnection();
        client.disconnectFuture.handle(() -> {
            luaDebug.sendEvent(new ComposedEvent(thread,{
                reason: Exited,
                threadId: client.clID
            }));
            client.disconnect(); //mm...
            // clients[clID] = null;
        });
        return client;
    }

    function newServer(pipeSocket:PipeSocket) {
        final clID = SERVER_ID;
        final server = new Server(pipeSocket,clID);
        clients.push(server);
        pipeSocket.assignRead((buf) -> readFunc(buf,clID));
        pipeSocket.beginConnection();
        server.disconnectFuture.handle(() -> {
            luaDebug.sendEvent(new ComposedEvent(thread,{
                reason: Exited,
                threadId: server.clID
            }));
            server.disconnect();
            // clients[clID] = null;
        });
        return server;
    }

    function continueAquireServer(serverLoc:String,timeout:Int):Promise<Server> {
        invalidatePreviousConnections(serverLoc,serverSlots);
        var timeoutTime = haxe.Timer.stamp() + timeout;
        function nextConnection(results:Array<Outcome<PipeSocket,Error>>):Promise<Server> {
            var chosenServer = null;
            for (result in results) {
                trace(result);
                switch (result) {
                    case Success(pipeSocket):
                        if (chosenServer != null) return Promise.reject(new Error("More than one server =("));
                        chosenServer = pipeSocket;
                    case Failure(err):
                        trace(err.message);
                }
            }
            if (chosenServer != null) {
                var server = newServer(chosenServer);
                return Promise.resolve(server);
            }

            if (haxe.Timer.stamp() > timeoutTime) {
                return Promise.reject(new Error(0,"timeout"));
            }
            trace("Running again.");
            return connectionProcess(serverLoc,serverSlots).inSequence().next(nextConnection);
        }
        return connectionProcess(serverLoc,serverSlots).inSequence().next(nextConnection);
    }

    public function getClients():Array<BaseConnected> {
        return clients;
    }

    public function attemptServer(serverLoc:String,timeout:Int):Promise<Server> {
        return continueAquireServer(gmodLocToSlotLoc(serverLoc),timeout);
    }

    public function firstClient(clientLoc:String) {
        invalidatePreviousConnections(gmodLocToSlotLoc(clientLoc),clientSlots);
    }

    public function attemptClient(clientLoc:String):Future<Array<Client>> {
        return aquireClients(gmodLocToSlotLoc(clientLoc),clientSlots);
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

typedef ClientID = Int;

typedef ReadWithClientID = (buf:Buffer,id:Int) -> Void;

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
