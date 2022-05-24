package gmdebug.dap;

import haxe.Timer;
import js.node.Timers;
import gmdebug.dap.clients.ClientStorage;
import gmdebug.Util.recurseCopy;
import gmdebug.dap.Validate;
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
using gmdebug.dap.DapFailure;
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

	public final commMethod:CommMethod;

	public var dapMode:DapMode;

	public var serverFolder:String;

	public var programs:Programs;

	public var shouldAutoConnect:Bool;

	public var requestArguments:Null<GmDebugLaunchRequestArguments>;

	var requestRouter:RequestRouter;

	var clientLocation:String;

	var bytesProcessor:BytesProcessor;

	var prevRequests:PreviousRequests;

	var clients:ClientStorage;

	public var shutdownActive(default,null):Bool;

	public function new(?x, ?y) {
		super(x, y);
		clientLocation = null;
		serverFolder = null;
		dapMode = ATTACH;
		commMethod = Pipe;
		programs = {
			xdotool : false
		}
		requestArguments = null;
		bytesProcessor = new BytesProcessor();
		prevRequests = new PreviousRequests();
		clients = new ClientStorage(readGmodBuffer);
		requestRouter = new RequestRouter(this,clients,prevRequests);
		poking = false;
		Node.process.on("uncaughtException", uncaughtException);
		Node.process.on("SIGTRM", shutdown);
		shutdownActive = false;
		Sys.setCwd(HxPath.directory(HxPath.directory(Sys.programPath())));
		checkPrograms();
		shouldAutoConnect = false;
	}

	public function initFromRequest(req:Request<Dynamic>,args:GmDebugLaunchRequestArguments) {
		final serverFolderResult = validateServerFolder(args.serverFolder);
		requestArguments = args;
		if (serverFolderResult != None) {
			serverFolderResult.sendError(req,this);
			return;
		}
		final serverSlash = HxPath.addTrailingSlash(args.serverFolder);
		serverFolder = serverSlash;
		var programPath = switch (args.programPath) {
			case null:
				req.composeFail("Gmdebug requires the property \"programPath\" to be specified when launching.", {
					id: 2,
					format: "Gmdebug requires the property \"programPath\" to be specified when launching",
				}).send(this);
				return;
			case "auto":
				if (Sys.systemName() == "Windows") {
					'$serverFolder/../srcds.exe';
				} else {
					'$serverFolder/../srcds_run';
				}
			case path:
				path;
		}
		if (!HxPath.isAbsolute(programPath)) {
			programPath = HxPath.join([serverFolder,programPath]);
		}
		final programPathResult = validateProgramPath(programPath);
		if (programPathResult != None) {
			programPathResult.sendError(req,this);
			return;
		}
		shouldAutoConnect = args.autoConnectLocalGmodClient.or(false);
		var childProcess = new LaunchProcess(programPath,this,args.programArgs);
		if (args.noDebug) {
			dapMode = LAUNCH(childProcess);
			serverFolder = HxPath.addTrailingSlash(args.serverFolder);
			final comp = (req : LaunchRequest).compose(launch,{});
			comp.send(this);
			return;
		}
		generateInitFiles(serverFolder);
		copyLuaFiles(serverFolder);
		var clientFolder = args.clientFolder;
		if (clientFolder != null) {
			final clientFolderResult = validateClientFolder(clientFolder);
			if (clientFolderResult != None) {
				clientFolderResult.sendError(req,this);
				return;
			}
			clientFolder = HxPath.addTrailingSlash(clientFolder);
		}
		setClientLocation(clientFolder);
		dapMode = LAUNCH(childProcess);
		startServer(req);
		
	}

	function copyLuaFiles(serverFolder:String) {
		final addonFolder = HxPath.join([serverFolder, "addons"]);
		recurseCopy('generated',addonFolder,(_) -> true);
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
		try {
			pokeServerTimeout();
			startPokeClients();
		} catch (e) {
			shutdown();
			throw e;
		}		
	}

	function checkPrograms() {
		if (Sys.systemName() != "Linux") return;
		try {
			ChildProcess.execSync("xdotool --help");
			programs.xdotool = true;
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

	function pokeClients() {
		if (!poking || shutdownActive) return;
		playerTry(clientLocation).handle((out) -> {
			switch (out) {
				case Success(_):

				case Failure(err):
					trace(err);
			}
			Timers.setTimeout(pokeClients,1500);
		});
	}

	@:async function playerTry(clientLoc:String) {
		final cl = @:await clients.newClient(clientLoc);
		clients.sendClient(cl.clID,new ComposedGmDebugMessage(clientID, {id: cl.clID}));
		new ComposedEvent(thread, {
			threadId: cl.clID,
			reason: Started
		}).send(this);
		trace(cl.clID);
		setupPlayer(cl.clID);
		return Noise;
	}

	function setupPlayer(clientID:Int) {
		clients.sendClient(clientID, new ComposedGmDebugMessage(intialInfo, {location: serverFolder,dapMode : Launch}));
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
		if (!requestArguments.autoConnectLocalGmodClient) {
			return;
		}
		final sp = x.ip.split(":");
		final ip = if (x.isLan) {
			gmdebug.lib.js.Ip.address();
		} else {
			sp[0];
		}
		final port = sp[1];
		if (Sys.systemName() == "Linux") {
			js.node.ChildProcess.spawn('xdg-open steam://connect/$ip:$port', {shell: true}); //FIXME client injection. malicious ect. ect.
		} else {
			js.node.ChildProcess.spawn('start steam://connect/$ip:$port', {shell: true});
		}
	}

	function processCustomMessages(x:GmDebugMessage<Dynamic>) {
		switch (x.msg) {
			case playerAdded:
				//add name, when connect :)
				// playerAddedMessage(cast x.body).handle((out) -> {
				// 	switch (out) {
				// 		case Success(true):
				// 			trace("Whater a sucess");
				// 		case Success(false):
				// 			trace("Could not add a new player...");
				// 		case Failure(fail):
				// 			throw fail;
				// 	}
				// });
			case playerRemoved:
				// playerRemovedMessage(cast x.body);
			case serverInfo:
				serverInfoMessage(cast x.body);
			case clientID | intialInfo:
				throw "Wrong direction..?";
				
		}
	}

	@:await function pokeServerTimeout() {
		@:await Promise.retry(clients.newServer.bind(serverFolder),(data) -> {
			return if (data.elapsed > SERVER_TIMEOUT * 1000) {
				new Error(Timeout,"Poke serverNamedPipes timed out");
			} else {
				Noise;
			}
		}).eager();
		clients.sendServer(new ComposedGmDebugMessage(clientID, {id: 0}));
		switch (dapMode) {
			case ATTACH:
				clients.sendServer(new ComposedGmDebugMessage(intialInfo, {location: serverFolder, dapMode: Attach}));
			case LAUNCH(_):
				clients.sendServer(new ComposedGmDebugMessage(intialInfo, {location: serverFolder, dapMode: Launch}));
		}
	}

	var pokeClientCancel:Timeout;

	var poking:Bool;

	function startPokeClients() {
		if (clientLocation != null) {
			poking = true;		
			pokeClients();
		}
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
		switch (debugeeMessage.type) {
			case Event:
				final cmd = (cast debugeeMessage : Event<Dynamic>).event;
				trace('recieved event from debugee, $cmd');
				EventIntercepter.event(cast debugeeMessage, threadId, this);
				sendEvent(cast debugeeMessage);
			case Response:
				final cmd = (cast debugeeMessage : Response<Dynamic>).command;
				trace('recieved response from debugee, $cmd');
				sendResponse(cast debugeeMessage);
			case "gmdebug":
				final cmd = (cast debugeeMessage : GmDebugMessage<Dynamic>).msg;
				trace('recieved gmdebug from debugee, $cmd');
				processCustomMessages(cast debugeeMessage);
			default:
				//NEVER ACCEPT A REVERSE REQUEST!!!
				throw "unhandled";
		}
	}

	override public function shutdown() {
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
		final dir = HxPath.join([serverFolder,"addons","debugee"]);
		if (Fs.existsSync(dir)) {
			untyped Fs.rmSync(dir,{recursive : true, force : true});
		}
		trace("Final shutdown active");
		super.shutdown();
	}


	public function setClientLocation(a:String) {
		return clientLocation = a;
	}

	public override function handleMessage(message:ProtocolMessage) {
		switch (message.type) {
			case Request:
				final request:Request<Dynamic> = cast message;
				trace('recieved request from client ${request.command}');
				try {
					requestRouter.route(cast message);

				} catch (e) {
					trace('Failed to handle message ${e.toString()}');
					trace(e.stack);
					final fail = (cast message : Request<Dynamic>).composeFail(e.message,{
						id: 15,
						format: e.toString()
					});
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
