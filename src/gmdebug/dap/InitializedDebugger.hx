package gmdebug.dap;

import node.Child_process;
import tink.CoreApi;
import js.node.buffer.Buffer;
import gmdebug.Util.recurseCopy;
import sys.FileSystem;
import gmdebug.composer.ComposedEvent;
import gmdebug.composer.ComposedRequest;
using gmdebug.composer.ComposeTools;
import gmdebug.GmDebugMessage;
import node.Fs;
import gmdebug.dap.clients.ClientStorage;
import gmdebug.composer.ComposedGmDebugMessage;
import global.nodejs.Timeout;
import vscode.debugProtocol.DebugProtocol;
import haxe.io.Path as HxPath;


interface InitializedDebugger {
    final initBundle:InitBundle;
}

@:await
class InitializedDebuggerDef implements InitializedDebugger {

    static final SERVER_TIMEOUT = 15; //thanks peanut brain

    var dapMode:DapMode;

    public final initBundle:InitBundle;

    final clients:ClientStorage;
    
    final luaDebug:LuaDebugger;


    // public var shutdownActive(default,null):Bool;

    var requestRouter:RequestRouter;

    var bytesProcessor:BytesProcessor;

    var prevRequests:PreviousRequests;


    
    var eventIntercepter:EventIntercepter;

    var responseIntercepter:ResponseIntercepter;

    var workspaceFolder:String;

    var pokeClientCancel:Timeout;

    var poking:Bool;

    public function new(_initBundle:InitBundle,_clients:ClientStorage,_bytesProcessor:BytesProcessor) {
        initBundle = _initBundle;
        clients = _clients;
        
        dapMode = LAUNCH(childProcess);
        startServer(req);
    }

    public function onInit(args:GmDebugLaunchRequestArguments) {
        generateInitFiles(initBundle.serverFolder);
        copyGmDebugLuaFiles(initBundle.serverFolder);
        if (!args.noCopy) {
            copyProjectFiles(args.copyAddonBaseFolder,args.copyAddonName);
        }
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
        resp.send(luaDebug);
        pokeServerTimeout().handle((result) -> {
            switch (result) {
                case Success(server):
                    startPokeClients();
                case Failure(err):
                    luaDebug.shutdown();
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

  

    


    function setupPlayer(clientID:Int) {
        clients.sendClient(clientID, new ComposedGmDebugMessage(intialInfo, {dapMode : Launch}));
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
        }).send(luaDebug);
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
                clients.sendServer(new ComposedGmDebugMessage(intialInfo, {dapMode: Attach}));
            case LAUNCH(_):
                clients.sendServer(new ComposedGmDebugMessage(intialInfo, {dapMode: Launch}));
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
        if (!poking || luaDebug.shutdownActive) return;
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
                switch (eventIntercepter.event(cast debugeeMessage, threadId)) {
                    case NoSend:
                    case Send:
                        luaDebug.sendEvent(cast debugeeMessage);
                };
            case Response:
                final resp = (cast debugeeMessage : Response<Dynamic>);
                final cmd = resp.command;
                trace('$time DEBUGEE: recieved response, $cmd');
                responseIntercepter.intercept(resp,threadId);
                luaDebug.sendResponse(resp);
            case "gmdebug":
                final cmd = (cast debugeeMessage : GmDebugMessage<Dynamic>).msg;
                trace('$time DEBUGEE: recieved gmdebug, $cmd');
                processCustomMessages(cast debugeeMessage);
            default:
                throw "unhandled"; // this would be dumb...
        }
    }

}

enum DapMode {
    ATTACH;
    LAUNCH(child:LaunchProcess);
}
