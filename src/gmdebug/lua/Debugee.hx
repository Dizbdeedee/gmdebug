package gmdebug.lua;

import haxe.Json;
import gmod.libs.VguiLib;
import gmdebug.lua.managers.BreakpointManager;
import gmdebug.lua.managers.FunctionBreakpointManager;
import gmdebug.lua.managers.VariableManager;
import gmdebug.lua.io.PipeSocket;
import gmdebug.lua.handlers.IHandler.HandlerResponse;
import gmdebug.Cross;
import gmdebug.GmDebugMessage;
import gmod.libs.GameLib;
import gmdebug.lua.HandlerContainer;
import haxe.io.Input;
import gmdebug.lua.io.DebugIO;
import gmod.libs.FileLib;
import gmod.Gmod;
import haxe.Constraints.Function;
import lua.Lua;
import gmod.libs.PlayerLib;
import gmod.stringtypes.Hook.GMHook;
import gmod.libs.HookLib;
import gmod.libs.TimerLib;
import gmdebug.lib.lua.Protocol.TStoppedEvent;
import gmdebug.lib.lua.Protocol.StopReason;
import gmdebug.composer.*;
import gmod.libs.DebugLib;
import haxe.io.Path.join;

using Lambda;

using StringTools;
using gmdebug.composer.ComposeTools;
using tink.CoreApi;
using Safety;
using gmod.helpers.WeakTools;

#if client
import gmod.libs.ChatLib;
import gmod.libs.GuiLib;
#end

enum RecursiveGuard {
	NONE;
	TRACEBACK;
	POLL;
}

@:keep
class Debugee {

	static final CONNECT_TIMEOUT = 25;

	static final TIMEOUT_CONFIG = 5;

	public final POLL_TIME = 0.1;

	public var clientID:Int = 0; //go

	public var state:DebugState = WAIT; //go

	public var socketActive:Bool = false; //keep

	public var pauseLoopActive = false; //keep

	public var dapMode:Null<DapModeStr>;

	public var stepHeight(get,never):Int;

	public extern inline function get_stepHeight():Int {
		return stackHeight - StackConst.STEP;
	}

	public var baseDepth:Null<Int>;

	public var recursiveGuard:RecursiveGuard = NONE;

	public var stackHeight(get, never):Int;

	@:noCompletion
	public function get_stackHeight():Int {
		for (i in 1...999999) {
			if (DebugLib.getinfo(i + 1, "") == null) {
				return i;
			}
		}
		throw "No stack height";
	}

	public var tracebackActive = false;

	var hooksActive = false;

	public var socket(default, set):Null<DebugIO>;

	// SENT BY DEBUG CLIENT
	public var dest = "";

	@:noCompletion
	function set_socket(sock) {
		G.previousSocket = sock;
		return socket = sock;
	}

	public var pollActive = false;

	final outputter:Null<Outputter>;

	final sc:Null<SourceContainer>;

	final vm:Null<VariableManager>;

	final hc:Null<HandlerContainer>;

	final exceptions:Null<Exceptions>;

	final bm:Null<BreakpointManager>;

	final fbm:Null<FunctionBreakpointManager>;
	
	final customHandlers:Null<CustomHandlers>;


	function freeFolder(folder:String):Bool {
		return if (!FileLib.Exists(folder,DATA)) {
			true;
		} else if (!FileLib.Exists(join([folder,AQUIRED]),DATA)) {
			true;
		} else {
			false;
		}
	}

	function checkFreeSlots():String {
		if (freeFolder(FOLDER)) {
			return FOLDER;
		}
		for (i in 1...127) {
			if (freeFolder('$FOLDER$i')) {
				return '$FOLDER$i';
			}
		}
		throw "Can't find a free folder to claim";
	}

	function generateLocations(folder:String):PipeLocations {
		FileLib.CreateDir(folder);
		return {
			folder : folder,
			client_ready: join([folder,CLIENT_READY]),
			output: join([folder,OUTPUT]),
			input: join([folder,INPUT]),
			ready: join([folder,READY])
		}
	}

	public function start() {
		if (socketActive)
			return false;
		socket = try {
			new PipeSocket(generateLocations(checkFreeSlots()));
		} catch (e) {
			trace(e);
			Logger.log("No free locations");
			return false;
		}
		Logger.log("We made it");
		trace("Connected to server...");
		socketActive = true;
		sendMessage(new ComposedEvent(initialized));
		#if debugdump
		FileLib.CreateDir("gmdebugdump");
		Gmod.collectgarbage("collect");
		Mri.DumpMemorySnapshot("gmdebugdump", "Before", -1);
		#end
		#if server
		hookPlayer();
		sendMessage(new ComposedEvent(continued, {threadId: 0, allThreadsContinued: true}));
		#end
		if (!startLoop()) {
			trace("Failed to setup debugger after timeout");
			return false;
		}
		DebugHook.addHook(DebugLoop.debugloop, "c");
		exceptions.hooks();
		G.__gmdebugTraceback = traceback;
		HookLib.Add(ShutDown,"debugee-shutdown",() -> {
			shutdown();
		});
		hooksActive = true;
		return true;
	}

	@:access(sys.net.Socket)
	public inline function send(data:String) { // x:Dynamic
		var str:String = untyped __lua__("{0} .. {1} .. {2} .. {3}", "Content-Length: ", data.length, "\r\n\r\n", data);
		socket.output.unsafe().writeString(str); // awful perfomance with non native writing
		socket.output.unsafe().flush();
	}

	public inline function sendMessage(message:ComposedProtocolMessage) {
		send(Json.stringify(message));
	}

	final ignores:Map<String, Bool> = [];

	// currently only on first lines for now. can expand to tracebacks.
	inline function checkIgnoreError(_err:String) {
		return ignores.exists(_err);
	}

	inline function ignoreError(_err:String) {
		ignores.set(_err, true);
	}

	#if server
	function hookPlayer() {
		var tbl = lua.Table.create();
		for (x in tbl) {
			trace(x);
		}
		// HookLib.Add(PlayerConnect, "gmdebug-newplayer", (name, ip) -> {
		// 	new ComposedGmDebugMessage(playerAdded, {
		// 		name : name,

		// 	}).send();
		// });
		// HookLib.Add(PlayerDisconnected, "gmdebug-byeplayer", (ply) -> {
		// 	sendMessage(new ComposedGmDebugMessage(playerRemoved, {
		// 		playerID: ply.UserID()
		// 	}));
		// });
		// for (ply in PlayerLib.GetAll()) {
		// 	sendMessage(new ComposedGmDebugMessage(playerAdded, {
		// 		name: ply.Name(),
		// 		playerID: ply.UserID()
		// 	}));
		// }
	}
	#end

	public function traceback(err:Any) {
		final _err = err;
		if (pollActive) return err;
		if (checkIgnoreError(err))
			return _err;
		if (pauseLoopActive || tracebackActive) {
			trace('traceback failed... ${pauseLoopActive} $tracebackActive');
			return _err;
		}
		if (!hooksActive || !socketActive)
			return _err;
		tracebackActive = true;
		if (err is haxe.Exception) {
			startHaltLoop(Exception,  StackConst.EXCEPT, (err : haxe.Exception).message);
		} else {
			startHaltLoop(Exception, StackConst.EXCEPT, Gmod.tostring(err));
		}
		tracebackActive = false;
		return DebugLib.traceback(err);
	}

	inline function parseInput(x:Input):MessageResult {
		socket.unsafe().output.writeString("\004");
		socket.unsafe().output.flush();
		return Cross.recvMessage(x);
	}

	function recvMessage():RecvMessageResult {
		return try {
			switch (parseInput(socket.unsafe().input)) {
				case ACK:
					ACK;
				case MESSAGE(msg):
					MESSAGE(msg);
			}
		} catch (e:String) {
			if (e == "Error : timeout") {
				RecvMessageResult.TIMEOUT;
			} else {
				ERROR(e);
			}
		}
	}

	public function poll() {
		if (socket == null)
			return;
		try {
			final msg = switch (recvMessage()) {
				case ACK | TIMEOUT:
					return;
				case MESSAGE(msg):
					msg;
				case ERROR(s):
					throw s;
			}
			switch (chooseHandler(msg)) {
				case DISCONNECT:
					shutdown();
				case WAIT | CONTINUE | CONFIG_DONE:
			}
		} catch (e:haxe.Exception) {
			trace(e.toString());
		}

	}

	public function new() {
		Logger.init();
		DebugHook.addHook();
		if (G.previousSocket != null) {
			G.previousSocket.close();
		}
		vm = new VariableManager({
			debugee: this
		});
		sc = new SourceContainer({
			debugee: this
		});
		customHandlers = new CustomHandlers({
			debugee : this
		});
		outputter = new Outputter({
			vm: vm,
			debugee: this
		});
		bm = new BreakpointManager({
			debugee: this 
		});
		exceptions = new Exceptions(this);
		fbm = new FunctionBreakpointManager();
		hc = new HandlerContainer({
			vm : vm,
			debugee: this,
			fbm : fbm,
			bm : bm,
			exceptions: exceptions
		});
		DebugLoop.init({
			bm: bm,
			debugee: this,
			fbm: fbm,
			sc: sc,
			exceptions: exceptions
		});
		#if server
		GameLib.ConsoleCommand("sv_timeout 999999\n");
		#elseif client
		Gmod.RunConsoleCommand("cl_timeout", 999999);
		#end
		trace("before socketactive");
		var timeout = Gmod.SysTime() + CONNECT_TIMEOUT;
		while (!socketActive && Gmod.SysTime() < timeout) {
			start();
		}
		if (!socketActive) {
			trace("Could not connect to server!!");
			throw "Failed to connect to server";
		}
		TimerLib.Create("report-profling", 3, 0, () -> {
			DebugLoopProfile.report();
		});
		var pollTime = 0.0;
		HookLib.Add(GMHook.Think, "gmdebug-poll", () -> {
			if (Gmod.CurTime() > pollTime) {
				pollTime = Gmod.CurTime() + POLL_TIME;
				pollActive = true;
				poll();
				pollActive = false;
			}
		});
	}

	public function normalPath(x:String):String {
		if (x.charAt(0) == "@") {
			x = @:nullSafety(Off) x.substr(1);
		}
		x = '$dest$x';
		return x;
	}

	public function startHaltLoop(reason:StopReason, bd:Int, ?txt:String) {
		if (pauseLoopActive) return;
		pauseLoopActive = true;
		baseDepth = bd;
		final tstop:TStoppedEvent = {
			threadId: clientID,
			allThreadsStopped: false,
			reason: reason,
			text: txt
		}
		sendMessage(new ComposedEvent(stopped, tstop));
		trace("HALT LOOP");
		haltLoop();
	}

	#if debugdump
	@:expose("stopDump")
	public function stopDump() {
		Gmod.collectgarbage("collect");
		Mri.DumpMemorySnapshot("gmdebugdump", "after", -1);
		Mri.DumpMemorySnapshotComparedFile("gmdebugdump", "Compared", -1, "gmdebugdump/LuaMemRefInfo-All-[]-[before].txt",
			"gmdebugdump/LuaMemRefInfo-All-[]-[after].txt");
	}
	#end

	function shutdown() {
		DebugHook.addHook();
		socket.run((sock) -> {
			sock.close();
			socket = null;
		});
		hooksActive = false;
		socket = null;
		socketActive = false;
		trace("Debugging aborted");
		// Exceptions.unhookGamemodeHooks();
		// Exceptions.unhookEntityHooks();
	}

	function startLoop() {
		#if client return true; #end
		var success = false;
		final timeoutTime = Gmod.SysTime() + TIMEOUT_CONFIG;
		while (Gmod.SysTime() < timeoutTime) {
			final msg = switch (recvMessage()) {
				case ACK | TIMEOUT:
					continue;
				case MESSAGE(msg):
					msg;
				case ERROR(s):
					throw s;
			}
			switch (chooseHandler(msg)) {
				case WAIT | CONTINUE:
				case DISCONNECT:
					shutdown();
					success = false;
					break;
				case CONFIG_DONE:
					success = true;
					break;

			}
		}
		return success;
	}


	function haltLoop() {
		while (true) {
			final msg = switch (recvMessage()) {
				case ACK | TIMEOUT:
					continue;
				case MESSAGE(msg):
					msg;
				case ERROR(s):
					throw s;
			}
			switch (chooseHandler(msg)) {
				case WAIT | CONFIG_DONE:
				case CONTINUE:
					break;
				case DISCONNECT:
					shutdown();
					break;
			}
		}
		pauseLoopActive = false;
	}

	function chooseHandler(incoming:{type:String}):HandlerResponse {
		return switch (incoming.type) {
			case null:
				throw "message sent to us had a null type";
			case "gmdebug":
				customHandlers.handle(cast incoming);
				WAIT; // this is a safe option in all scenarios.
			case MessageType.Request:
				hc.handlers(cast incoming);
			default:
				throw "message sent to us had an unknown type";
		}
	}

	public function fullPathToGmod(fullPath:String):Option<GmodPath> {
		return if (fullPath.contains(dest)) {
			var result = fullPath.replace(dest, "");
			result = "@" + result;
			Some(cast result);
		} else {
			None;
		}
	}
}

typedef LineMap = Map<Int, Bool>;

// TODO
@:native("_G") private extern class G {
	static var previousSocket:Null<DebugIO>;

	static dynamic function __gmdebugTraceback(err:Any):Any;
}

enum DebugState {
	WAIT;
	STEP(targetHeight:Null<Int>);
	OUT(outFunc:Function, lowestLine:Int,targetHeight:Int);
}

enum RecvMessageResult {
	TIMEOUT;
	ACK;
	ERROR(s:String);
	MESSAGE(msg:Dynamic);

}