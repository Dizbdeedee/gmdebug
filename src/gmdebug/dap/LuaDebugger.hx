package gmdebug.dap;

import js.html.SetInterval;
import haxe.Timer;
import js.node.Timers;
import gmdebug.dap.clients.ClientStorage;
import gmdebug.Util.recurseCopy;
import js.Node;
import sys.FileSystem;
import gmdebug.composer.*;
import js.node.Fs;
import vscode.debugProtocol.DebugProtocol;
import js.node.Buffer;
import haxe.io.Path as HxPath;
import js.node.net.Socket;
import vscode.debugAdapter.DebugSession;
import gmdebug.Cross;
import js.node.ChildProcess;
using tink.CoreApi;
using gmdebug.composer.ComposeTools;

import gmdebug.GmDebugMessage;

using Lambda;

typedef Programs = {
    xdotool : Bool
}

@:keep @:await class LuaDebugger extends DebugSession {

    static final SERVER_TIMEOUT = 15; //thanks peanut brain

    public var dapMode:DapMode;

    public var initBundle:InitBundle;

    public var shutdownActive(default,null):Bool;

    var requestRouter:RequestRouter;

    var bytesProcessor:BytesProcessor;

    var prevRequests:PreviousRequests;

    var clients:ClientStorage;

    var workspaceFolder:String;

    var pokeClientCancel:Timeout;

    var poking:Bool;

    public function new(?x, ?y, _workspaceFolder:String) {
        super(x, y);
        dapMode = ATTACH;
        workspaceFolder = _workspaceFolder;
        bytesProcessor = new BytesProcessor();
        prevRequests = new PreviousRequests();
        clients = new ClientStorageDef(readGmodBuffer,this);
        requestRouter = new RequestRouter(this,clients,prevRequests);
        poking = false;
        Node.process.on("uncaughtException", uncaughtException);
        Node.process.on("SIGTRM", shutdown);
        shutdownActive = false;
        Sys.setCwd(HxPath.directory(HxPath.directory(Sys.programPath())));
        checkPrograms();
    }

    public function initFromRequest(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments) {
        switch (InitBundle.initBundle(req,args,this)) {
            case Success(_initBundle):
                initBundle = _initBundle;
                var childProcess = new LaunchProcess(initBundle.programPath,this,initBundle.programArgs);
                if (args.noDebug) {
                    dapMode = LAUNCH(childProcess);
                    final comp = (req : LaunchRequest).compose(launch,{});
                    comp.send(this);
                    return;
                }
                generateInitFiles(initBundle.serverFolder);
                copyGmDebugLuaFiles(initBundle.serverFolder);
                if (!args.noCopy) {
                    copyProjectFiles(args.copyAddonBaseFolder,args.addonName);
                }
                dapMode = LAUNCH(childProcess);
                startServer(req);
            case Failure(e):
                trace(e);
                throw "Couldn't create initBundle";

        };
    }

    function copyGmDebugLuaFiles(serverFolder:String) {
        final addonFolder = HxPath.join([serverFolder, "addons"]);
        recurseCopy('generated',addonFolder,(_) -> true);
    }

    function copyProjectFiles(relative:String,addonName:String) {
        final luaAddon = HxPath.join([workspaceFolder,relative]);
        final destination = HxPath.join([initBundle.serverFolder,"addons",addonName]);
        if (!Fs.existsSync(destination)) {
            Fs.mkdirSync(destination);
        }
        recurseCopy(luaAddon,destination,(file -> {trace(file); return file.charAt(0) != ".";}));
    }

    function generateInitFiles(serverFolder:String) {
        final initFile = HxPath.join([serverFolder,"lua","includes","init.lua"]);
        final backupFile = HxPath.join(["generated","debugee","lua","includes","init_backup.lua"]);
        final initContents = if (FileSystem.exists(initFile)) {
            sys.io.File.getContent(initFile);
        } else if (FileSystem.exists(backupFile)) {
            sys.io.File.getContent(backupFile);
        } else {
            throw "Could not find real, or backup file >=(";
        }
        final appendFile = HxPath.join(["generated","debugee","lua","includes","init_attach.lua"]);
        final appendContents = if (FileSystem.exists(appendFile)) {
            sys.io.File.getContent(appendFile);
        } else {
            throw "Could not find append file...";
        }
        final ourInitFile = HxPath.join(["generated","debugee","lua","includes","init.lua"]);
        sys.io.File.saveContent(ourInitFile,initContents + appendContents);
    }

    /**
     * Async start server. Respond to attach request when attached.
    **/
    function startServer(attachReq:Request<Dynamic>) {
        final resp = attachReq.compose(attach);
        resp.send(this);
        pokeServerTimeout().handle((result) -> {
            switch (result) {
                case Success(server):
                    startPokeClients();
                case Failure(err):
                    shutdown();
                    throw err;
        }});
    }

    function checkPrograms() {
        if (Sys.systemName() != "Linux") return;
        try {
            ChildProcess.execSync("xdotool --help");
            initBundle.programs.xdotool = true;
        } catch (e) {
            trace("Xdotool not found");
            trace(e.toString());
        }
    }

    function uncaughtException(err:js.lib.Error, origin) {
        trace(err.message);
        trace(err.stack);
        // shutdown();
    }

    


    function setupPlayer(clientID:Int) {
        clients.sendClient(clientID, new ComposedGmDebugMessage(intialInfo, {location: initBundle.serverFolder,dapMode : Launch}));
        clients.sendClient(clientID, new ComposedGmDebugMessage(GmMsgType.clientID, {id: clientID}));
        prevRequests.get(setBreakpoints).run((msg) -> clients.sendClient(clientID,msg));
        prevRequests.get(setExceptionBreakpoints).run((msg) -> clients.sendClient(clientID,msg));
        prevRequests.get(setFunctionBreakpoints).run((msg) -> clients.sendClient(clientID,msg));
        clients.sendClient(clientID, new ComposedRequest(configurationDone, {}));
    }

    // todo
    function playerRemovedMessage(x:GMPlayerRemovedMessage) {
        new ComposedEvent(thread, {
            threadId: clients.getByGmodID(x.playerID).clID,
            reason: Exited
        }).send(this);
    }

    function serverInfoMessage(x:GMServerInfoMessage) {
        final sp = x.ip.split(":");
        final ip = if (x.isLan) {
            gmdebug.lib.js.Ip.address();
        } else {
            sp[0];
        }
        final port = sp[1];
        if (initBundle.requestArguments.clients == 1) {
            if (Sys.systemName() == "Linux") {
                js.node.ChildProcess.spawn('xdg-open steam://connect/$ip:$port', {shell: true}); //FIXME client injection. malicious ect. ect.
            } else {
                js.node.ChildProcess.spawn('start steam://connect/$ip:$port', {shell: true});
            }
        }
        //TODO: proton
        if (!initBundle.requestArguments.noDebug && initBundle.requestArguments.clients > 1) {
            for (_ in 0...initBundle.requestArguments.clients) {
                openMultirun(ip,port);
            }
        }
    }

    function openMultirun(ip:String,port:String) {
        var mrOptions = "";
        if (initBundle.requestArguments.multirunOptions != null) {
            mrOptions = initBundle.requestArguments.multirunOptions.join(" ");
        }
        trace(mrOptions);
        final hl2 = HxPath.join([initBundle.clientLocation,"..","hl2.exe"]);
        trace('$hl2 ${Fs.existsSync(hl2);}');
        js.node.ChildProcess.spawn('"$hl2" -multirun -condebug $mrOptions +sv_lan 1 +connect $ip:$port',{shell : true});
    }

    function processCustomMessages(x:GmDebugMessage<Dynamic>) {
        switch (x.msg) {
            case playerAdded:
                //add name, when connect :)
                // playerAddedMessage(cast x.body).handle((out) -> {
                //  switch (out) {
                //      case Success(true):
                //          trace("Whater a sucess");
                //      case Success(false):
                //          trace("Could not add a new player...");
                //      case Failure(fail):
                //          throw fail;
                //  }
                // });
            case playerRemoved:
                // playerRemovedMessage(cast x.body);
            case serverInfo:
                serverInfoMessage(cast x.body);
            case clientID | intialInfo:
                throw "Wrong direction..?";

        }
    }

    @:async function pokeServerTimeout() {
        var server = @:await clients.attemptServer(initBundle.serverFolder,SERVER_TIMEOUT);
        clients.sendServer(new ComposedGmDebugMessage(clientID, {id: 0}));
        switch (dapMode) {
            case ATTACH:
                clients.sendServer(new ComposedGmDebugMessage(intialInfo, {location: initBundle.serverFolder, dapMode: Attach}));
            case LAUNCH(_):
                clients.sendServer(new ComposedGmDebugMessage(intialInfo, {location: initBundle.serverFolder, dapMode: Launch}));
        }
        return Noise; //or server. who cares.
    }

    // static var pokeClients:

    function startPokeClients() {
        if (initBundle.clientLocation != null) {
            poking = true;
            trace("Poking the client");
            clients.firstClient(initBundle.clientLocation);
            // pokeClients();
            haxe.Timer.delay(pokeClients,500);
            // SetInterval.cal/l(pokeClients,500);
        }
    }

    function pokeClients() {
        if (!poking || shutdownActive) return;
        clients.attemptClient(initBundle.clientLocation).handle((clients) -> {
            for (newClient in clients) {
                trace('Setting up player: ${newClient.clID}');
                setupPlayer(newClient.clID);
            }
            // trace(clients);
            haxe.Timer.delay(pokeClients,500);

        });
    }


    function stopPokeClients() {
        if (poking != null) {
            poking = false;
            // js.node.
        }
    }

    function readGmodBuffer(jsBuf:Buffer, clientNo:Int) {
        final messages = bytesProcessor.process(jsBuf, clientNo);
        for (msg in messages) {
            processDebugeeMessage(msg, clientNo);
        }
        if (bytesProcessor.fillRequested) {
            clients.sendAnyRaw(clientNo,"\004\r\n");
        }
    }

    function processDebugeeMessage(debugeeMessage:ProtocolMessage, threadId:Int) {
        debugeeMessage.seq = 0; // must be done, or implementation has a fit
        var time = Sys.time();
        switch (debugeeMessage.type) {
            case Event:
                final cmd = (cast debugeeMessage : Event<Dynamic>).event;
                trace('$time DEBUGEE: recieved event, $cmd');
                EventIntercepter.event(cast debugeeMessage, threadId, this);
                sendEvent(cast debugeeMessage);
            case Response:
                final cmd = (cast debugeeMessage : Response<Dynamic>).command;
                trace('$time DEBUGEE: recieved response, $cmd');
                sendResponse(cast debugeeMessage);
            case "gmdebug":
                final cmd = (cast debugeeMessage : GmDebugMessage<Dynamic>).msg;
                trace('$time DEBUGEE: recieved gmdebug, $cmd');
                processCustomMessages(cast debugeeMessage);
            default:
                throw "unhandled"; // this would be dumb...
        }
    }

    public override function shutdown() {

        shutdownActive = true;
        switch (dapMode) {
            case LAUNCH(child = {active : true}):
                child.write("quit\n");
                child.kill();
            default:
        }
        sendEvent(new ComposedEvent(terminated, {}));
        sendEvent(new ComposedEvent(exited,{exitCode: 0}));
        clients.disconnectAll();
        final dir = HxPath.join([initBundle.serverFolder,"addons","debugee"]);
        if (Fs.existsSync(dir)) {
            untyped Fs.rmSync(dir,{recursive : true, force : true});
        }
        trace("Final shutdown active");
        super.shutdown();
    }

    public override function handleMessage(message:ProtocolMessage) {
        var time = Sys.time();
        switch (message.type) {
            case Request:
                final request:Request<Dynamic> = cast message;
                trace('$time MASTER: recieved request ${request.command} ${request}');
                try {
                    requestRouter.route(cast message);

                } catch (e) {
                    trace('Failed to handle message ${e.toString()}');
                    trace(e.stack);
                    final fail = (cast message : Request<Dynamic>).composeFail(DEBUGGER_UNSPECIFIED_ERROR, {err : e.toString()});
                    fail.send(this);
                    throw e;
                }
            default:
                trace('Sent message type ${message.type} from dap. Not a request: not handling');
        }
    }
}

typedef FileSocket = {
    readS:Socket,
    writeS:Socket,
}

enum DapMode {
    ATTACH;
    LAUNCH(child:LaunchProcess);
}
