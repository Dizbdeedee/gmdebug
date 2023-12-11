package gmdebug.lua;

import gmdebug.lua.debugcontext.DebugContext;
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

    // public var baseDepth:Null<Int>;

    public var recursiveGuard:RecursiveGuard = NONE;

    public var stackHeight(get, never):Int;

    @:noCompletion
    public function get_stackHeight():Int {
        for (i in 1...999999) {
            if (DebugLib.getinfo(i, "") == null) {
                return i - 2; //non inline, last null is not an actual height.
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

    var aquiringSocket:PipeSocket;

    public var pollActive = false;

    final outputter:Null<Outputter>;

    final sc:Null<SourceContainer>;

    final vm:Null<VariableManager>;

    final hc:Null<HandlerContainer>;

    final exceptions:Null<Exceptions>;

    final bm:Null<BreakpointManager>;

    final fbm:Null<FunctionBreakpointManager>;

    final customHandlers:Null<CustomHandlers>;

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
        customHandlers = new CustomHandlers();
        outputter = new Outputter({
            vm: vm,
            debugee: this
        });
        bm = new BreakpointManager({
            debugee: this
        });
        exceptions = new Exceptions(this.traceback);
        fbm = new FunctionBreakpointManager();
        hc = new HandlerContainer({
            vm : vm,
            debugee: this,
            fbm : fbm,
            bm : bm,
            exceptions: exceptions,
            sc : sc
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
        Lua.print("Attempting connection to gmdebug... please wait");
        var timeout = Gmod.SysTime() + CONNECT_TIMEOUT;
        while (!socketActive && Gmod.SysTime() < timeout) {
            start();
        }
        if (!socketActive) {
            trace("GMDEBUG FAILED TO CONNECT");
            Logger.log("GMDEBUG FAILED TO CONNECT");
            aquiringSocket.close();
            shutdown();
            throw "Failed to connect to server";
        }
        Logger.log("GMDEBUG CONNECTED SUCCESSFULLY");
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

    function freeFolder(folder:String):Bool {
        return if (!FileLib.Exists(folder,DATA)) {
            true;
        } else if (!FileLib.Exists(join([folder,PATH_CLIENT_READY]),DATA)
        && !FileLib.Exists(join([folder,PATH_CONNECTION_AQUIRED]),DATA)
        && !FileLib.Exists(join([folder,PATH_CONNECTION_IN_PROGRESS]),DATA)
        ) {
            true;
        } else {
            false;
        }
    }

    function checkFreeSlots():String {
        for (i in 0...127) {
            if (freeFolder('$PATH_FOLDER$i')) {
                return '$PATH_FOLDER$i';
            }
        }
        throw "Can't find a free folder to claim";
    }

    function generateLocations(folder:String):PipeLocations {
        FileLib.CreateDir(folder);
        return generatePipeLocations(folder);
    }

    public function start() {
        if (socketActive)
            return false;
        if (aquiringSocket == null) {
            aquiringSocket = new PipeSocket(generateLocations(checkFreeSlots()));
        }
        final result = aquiringSocket.aquire();
        if (result != AQUIRED) {
            return false;
        }
        socket = aquiringSocket;
        trace("GMDEBUG SUCCESSFULLY CONNECTED");
        socketActive = true;
        sendMessage(new ComposedEvent(initialized));
        #if debugdump
        FileLib.CreateDir("gmdebugdump");
        Gmod.collectgarbage("collect");
        Mri.DumpMemorySnapshot("gmdebugdump", "Before", -1);
        #end
        #if server
        sendMessage(new ComposedEvent(continued, {threadId: 0, allThreadsContinued: true}));
        #end
        if (!startLoop()) {
            return false;
        }
        DebugHook.addHook(DebugLoop.debugloop, "c");
        exceptions.hooks();
        G.__gmdebugTraceback = traceback;
        HookLib.Add(ShutDown,"debugee-shutdown",() -> {
            shutdown();
        });
        outputter.hookPrint();
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

    public function traceback(err:Any, ?alt:Int) {
        final _err = err;
        if (pollActive) return err;
        if (pauseLoopActive || tracebackActive) {
            trace('traceback failed... ${pauseLoopActive} $tracebackActive');
            return _err;
        }
        if (!hooksActive || !socketActive)
            return _err;
        tracebackActive = true;
        Lua.print('ALT $alt');
        Util.traceStack();
        if (alt == null) alt = 0;
        DebugContext.enterDebugContextSet(3 + alt);
        if (err is haxe.Exception) {
            DebugContext.debugContext({startHaltLoop(Exception, (err : haxe.Exception).message);});
        } else {
            DebugContext.debugContext({startHaltLoop(Exception, Gmod.tostring(err));});
        }
        DebugContext.exitDebugContext();
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
        Gmod.xpcall(() -> {
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
                    trace("poll()/Debugee - request for disconnect from poll");
                    shutdown();
                case PAUSE(pauseReq):
                    var resp = pauseReq.compose(pause,{});
                    sendMessage(resp);
                    DebugContext.enterDebugContextSet(5);
                    DebugContext.debugContext({startHaltLoop(Pause);});
                    DebugContext.exitDebugContext();
                case WAIT | CONTINUE | CONFIG_DONE:
            }
        },(err) -> {
            trace(err);
            DebugLib.Trace();
        });


    }


    public function startHaltLoop(reason:StopReason, ?txt:String) {
        if (pauseLoopActive) return;
        pauseLoopActive = true;
        final tstop:TStoppedEvent = {
            threadId: clientID,
            reason: reason,
            text: txt
        }
        DebugContext.markNotReport();
        sendMessage(new ComposedEvent(stopped, tstop));
        DebugContext.markReport();
        trace("HALT LOOP");
        DebugContext.debugContext({haltLoop();});
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
        trace("Debugee - We've shutdown debugging");
    }

    function startLoop() {
        #if client return true; #end
        var success = false;
        final timeoutTime = Gmod.SysTime() + TIMEOUT_CONFIG;
        while (Gmod.SysTime() < timeoutTime) {
            DebugContext.markNotReport();
            final msg = switch (recvMessage()) {
                case ACK | TIMEOUT:
                    continue;
                case MESSAGE(msg):
                    msg;
                case ERROR(s):
                    throw s;
            }
            DebugContext.markReport();
            var handlerResponse = DebugContext.debugContext({chooseHandler(msg);});
            switch (handlerResponse) {
                case WAIT | CONTINUE:
                case PAUSE(pauseReq):
                    trace("Cannot pause right now!");
                    var resp = pauseReq.composeFail(GMOD_CANNOT_PAUSE);
                    sendMessage(resp);
                    shutdown();
                    success = false;
                    break;
                case DISCONNECT:
                    trace("startLoop()/Debugee - request for disconnect from startloop");
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
            DebugContext.markNotReport();
            final msg = switch (recvMessage()) {
                case ACK | TIMEOUT:
                    continue;
                case MESSAGE(msg):
                    msg;
                case ERROR(s):
                    throw s;
            }
            DebugContext.markReport();
            var handlerResponse = DebugContext.debugContext({chooseHandler(msg);});
            switch (handlerResponse) {
                case WAIT | CONFIG_DONE:
                case PAUSE(pauseReq):
                    trace("Cannot pause right now!");
                    var resp = pauseReq.composeFail(GMOD_CANNOT_PAUSE);
                    DebugContext.markNotReport();
                    sendMessage(resp);
                    DebugContext.markReport();
                case CONTINUE:
                    break;
                case DISCONNECT:
                    trace("haltLoop()/Debugee - request for disconnect from haltLoop");
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
                var result;
                DebugContext.debugContext({result = customHandlers.handle(cast incoming);});
                switch (result) {
                    case CLIENT_ID(id):
                        clientID = id;
                    case INITIAL_INFO(_dest,_dapMode):
                        dest = _dest;
                        dapMode = _dapMode;
                }
                WAIT; // this is a safe option in all scenarios.
            case MessageType.Request:
                DebugContext.debugContext({hc.handlers(cast incoming);});
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

    static dynamic function __gmdebugTraceback(err:Any,?alt:Int):Any;
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