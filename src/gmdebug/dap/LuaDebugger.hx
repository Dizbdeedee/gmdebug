package gmdebug.dap;

import gmdebug.dap.EventIntercepter;
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
import js.node.child_process.ChildProcess;
import gmdebug.GmDebugMessage;
import gmdebug.dap.ResponseIntercepter;
import gmdebug.dap.GmodClientOpener;
import js.node.stream.Readable;
import js.node.stream.Writable;
import gmdebug.dap.LaunchProcessor;
import gmdebug.dap.FileWatcher;
import gmdebug.dap.Log;

using tink.CoreApi;
using gmdebug.composer.ComposeTools;
using StringTools;
using Lambda;

typedef Programs = {
    xdotool : Bool
}

enum LineStore {
    LAST_SPLIT(x:String);
    NO_SPLIT;
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

    var eventIntercepter:EventIntercepter;

    var gmodClientOpener:GmodClientOpener;

    var responseIntercepter:ResponseIntercepter;

    var launchProcessor:LaunchProcessor;

    var fileWatcher:FileWatcher;

    public var workspaceFolder:String; //oh dear

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
        eventIntercepter = new EventIntercepterDef(this);
        responseIntercepter = new ResponseIntercepterDef();
        gmodClientOpener = new GmodClientOpenerMultirun();
        launchProcessor = new LaunchProcessorDef();
        fileWatcher = new FileWatcherDef();
        poking = false;
        Node.process.on("uncaughtException", uncaughtException);
        Node.process.on("SIGTRM", shutdown);
        shutdownActive = false;
        Sys.setCwd(HxPath.directory(HxPath.directory(Sys.programPath())));
        checkPrograms();
    }

    function initFromBundle(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments,initBundle:InitBundle) {
        var launchProcessOpt = if (Sys.systemName() == "Linux") {
            launchProcessor.launchLinux(initBundle.programPath,initBundle.argString,initBundle.serverPort);
        } else {
            launchProcessor.launchWindows(initBundle.programPath,initBundle.argString,initBundle.serverPort);
        }
        var childProcess = switch (launchProcessOpt) {
            case Some(launchProcess):
                launchProcess;
            case None:
                trace("initFromRequest: UNABLE TO LAUNCH PROCESS");
                throw "InitFromRequest: Unable to launch process";
        }
        if (args.noDebug) {
            dapMode = LAUNCH(childProcess);
            final comp = (req : LaunchRequest).compose(launch,{});
            comp.send(this);
            return;
        }
        generateInitFiles(initBundle.serverFolder);
        copyGmDebugLuaFiles();
        if (!args.noCopy) {
            copyProjectFiles();
            fileWatcher.watch(initBundle);
        }
        dapMode = LAUNCH(childProcess);
        childProcessSetup(childProcess);
        final resp = req.compose(attach);
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

    function childProcessSetup(childProcess:ChildProcess) {
        childProcess.on("error", (err) -> {
            new ComposedEvent(output, {
                category: Stderr,
                output: err.message + "\n" + err.stack,
                data: null
            }).send(this);
            shutdown();
        });
        childProcess.on("exit", (sig) -> {
            new ComposedEvent(output, {
                category: Stderr,
                output: "Gmod Server exited with code:" + sig,
                data: null
            }).send(this);
            shutdown();
        });
        var createEventWritable = new Writable({
            write: createEventFromStdout
        });
        childProcess.stdout.pipe(createEventWritable, {end: false});
        childProcess.stderr.pipe(createEventWritable, {end: false});
    }

    public function initFromRequest(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments) {
        initBundle = switch (InitBundle.initBundle(req,args,this)) {
            case Success(_initBundle):
                _initBundle;
            case Failure(e):
                trace(e);
                throw "Couldn't create initBundle";
        };
        initFromBundle(req,args,initBundle);
    }

    function copyGmDebugLuaFiles() {
        recurseCopy('generated',initBundle.serverAddonFolder,(_) -> true);
    }

    function copyProjectFiles() {
        if (!Fs.existsSync(initBundle.luaAddonDestination)) {
            Fs.mkdirSync(initBundle.luaAddonDestination);
        }
        recurseCopy(initBundle.luaAddon,initBundle.luaAddonDestination,(file -> {trace(file); return file.charAt(0) != ".";}));
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


    function checkPrograms() {
        if (Sys.systemName() != "Linux") return;
        try {
            js.node.ChildProcess.execSync("xdotool --help");
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

    function setupReadables(readables:Array<IReadable>) {
        var lineStore:Array<LineStore> = [];
        for (i in 0...readables.length) {
            lineStore[i] = NO_SPLIT;
            var read = readables[i];
            read.on("data",onReadableData.bind(_,i,lineStore));
        }
    }

    function onReadableData(buff:global.Buffer,id:Int,lineStore:Array<LineStore>) {
        var str = buff.toString();
        var lineSplit = str.split("\r\n");
        if (lineSplit.length == 1) {
            lineStore[id] = switch (lineStore[id]) {
                case LAST_SPLIT(lastline):
                    LAST_SPLIT(lastline + lineSplit[0]);
                case NO_SPLIT:
                    LAST_SPLIT(lineSplit[0]);
            }
            return;
        }
        trace(lineSplit);
        var firstLine = switch (lineStore[id]) {
            case LAST_SPLIT(lastline):
                lastline + lineSplit[0];
            case NO_SPLIT:
                lineSplit[0];
        }
        new ComposedEvent(output, {
            category: Stdout,
            output: firstLine + "\n",
            data: null
        }).send(this);
        for (y in 1...lineSplit.length - 1) {
            new ComposedEvent(output, {
                category: Stdout,
                output: lineSplit[y] + "\n",
                data: null
            }).send(this);
        }
        var lastLine = lineSplit[lineSplit.length - 1];
        lineStore[id] = if (lastLine.length > 0) {
            LAST_SPLIT(lastLine);
        } else {
            NO_SPLIT;
        }
    }

    function launchClients() {
        var clfolder = switch (initBundle.clientLocation) {
            case None:
               return;
            case Some(clfolder):
                clfolder;
        }
        var clients = switch (initBundle.clients) {
            case None:
                return;
            case Some(clients):
                clients;
        }
        final mrOptions = initBundle.requestArguments.multirunOptions;
        final noDebug = initBundle.noDebug;
        final port = initBundle.serverPort;
        final noClients = initBundle.clients;
        final ip = gmdebug.lib.js.Ip.address();
        if (!noDebug && clients < 1) return;
        var promReadables = gmodClientOpener.open({ip: ip,port: port},clfolder,mrOptions,clients);
        promReadables.inSequence().handle((out) -> {
            switch (out) {
                case Success(readables):
                    setupReadables(readables);
                case Failure(err):
                    trace('gmodClientOpener&serverInfoMessage: Failure $err');
            }
        });
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
        launchClients();
        return Noise; //or server. who cares.
    }

    //move to clientpoker
    function startPokeClients() {
        var clfolder = switch (initBundle.clientLocation) {
            case None:
               return;
            case Some(clfolder):
                clfolder;
        }
        poking = true;
        trace("Poking the client");
        clients.firstClient(clfolder);
        haxe.Timer.delay(pokeClients,500);
    }


    function pokeClients() {
        if (!poking || shutdownActive) return;
        var clfolder = switch (initBundle.clientLocation) {
            case None:
               return;
            case Some(clfolder):
                clfolder;
        }
        clients.attemptClient(clfolder).handle((clients) -> {
            for (newClient in clients) {
                trace('Setting up player: ${newClient.clID}');
                setupPlayer(newClient.clID);
            }
            haxe.Timer.delay(pokeClients,500);
        });
    }


    function stopPokeClients() {
        if (poking != null) {
            poking = false;
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
                tracev('$time DEBUGEE: recieved event, $cmd');
                switch (eventIntercepter.event(cast debugeeMessage, threadId)) {
                    case NoSend:
                    case Send:
                        sendEvent(cast debugeeMessage);
                };
            case Response:
                final resp = (cast debugeeMessage : Response<Dynamic>);
                final cmd = resp.command;
                tracev('$time DEBUGEE: recieved response, $cmd');
                responseIntercepter.intercept(resp,threadId);
                sendResponse(resp);
            case "gmdebug":
                final cmd = (cast debugeeMessage : GmDebugMessage<Dynamic>).msg;
                tracev('$time DEBUGEE: recieved gmdebug, $cmd');
            default:
                throw "unhandled"; // this would be dumb...
        }
    }

    public override function shutdown() {
        shutdownActive = true;
        switch (dapMode) {
            case LAUNCH(child = {connected : true}):
                child.stdin.write("quit\n");
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

    function createEventFromStdout(chunk:Buffer, encoding, callback) {
        if (shutdownActive) return;
        var stringOutput = chunk.toString().replace("\r","");
        if (!stringOutput.contains(Cross.OUTPUT_INTERCEPTED)) {
            new ComposedEvent(output, {
                category: Stdout,
                output: stringOutput,
                data: null
            }).send(this);
        }
        callback(null);
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
    LAUNCH(child:ChildProcess);
}
