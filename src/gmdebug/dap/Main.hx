package gmdebug.dap;

import gmdebug.GmDebugMessage.GmDebugLaunchRequestArguments;
import gmdebug.dap.clients.ClientStorage;
import js.Syntax;
import js.node.ChildProcess;
import js.node.console.Console;
import js.node.Process;
import js.node.net.Server;
import js.node.Net;
import js.Node;
import sys.net.Host;
import js.node.net.Socket;
import vscode.debugAdapter.testSupport.DebugClient;
import vscode.debugAdapter.DebugSession;

using Lambda;

class Main {

    public static function main() {
        var args = Sys.args().slice(2);
        var port = 0;
        for (arg in args) {
            final portMatch = ~/^--server=(\d{4,5})$/;
            if (portMatch.match(arg)) {
                port = Std.parseInt(portMatch.matched(0));
            }
        }
        if (port > 0) {
            var server = Net.createServer((socket) -> {
                socket.on(End, () -> trace("Closed"));
                final session = new LuaDebugger(false, true);
                session.setRunAsServer(true);
                untyped session.start(socket, socket);
            });
            server.listen(4555, "localhost");
        } else {
            final session = new LuaDebugger(false);
            Node.process.on("SIGTRM", () -> session.shutdown());
            untyped session.start(Node.process.stdin, Node.process.stdout);
            // redirect traces to stderr
            haxe.Log.trace = (v, ?infos) -> {
                final str = haxe.Log.formatOutput(v, infos);
                Node.console.error(str);
            };
        }
    }

    public static function luaDebuggerInit(luaDebug:LuaDebugger):LuaDebuggerInitBundle {
        var bytesProcessor = new BytesProcessor();
        var previousRequests = new PreviousRequests();
        var clients = new ClientStorageDef(luaDebug.readGmodBuffer,luaDebug);
        var requestRouter = new RequestRouterInit(luaDebug,(req) -> {
            switch (initBundle(req,this)) {
                case Success(_initBundle):
                    initBundle = _initBundle;
                    var childProcess = new LaunchProcess(initBundle.programPath,this,initBundle.programArgs);
                    // if (args.noDebug) {
                    //     dapMode = LAUNCH(childProcess);
                    //     final comp = (req : LaunchRequest).compose(launch,{});
                    //     comp.send(this);
                    //     return;
                    // }
                    
                case Failure(e):
                    trace(e);
                    throw "Couldn't create initBundle";
    
            };
        });
        return {
            bytesProcessor: new BytesProcessor(),
            previousRequests: new PreviousRequests(),
            clients: new ClientStorageDef(readGmodBuffer,luaDebug),
            requestRouter: new RequestRouterInit(luaDebug,() -> {
                
            }),
            eventIntercepter: new EventIntercepterDef(luaDebug),
            responseIntercepter: new ResponseIntercepterDef(luaDebug),
            initalizedDebuggerFactory: () -> new InitalizedDebuggerDef()

        }
    }

    static function what() {
        
    }

    public static function initBundle(req:Request<Dynamic>,luadebug:LuaDebugger):Outcome<InitBundle,InitBundleException> {
        final args:GmDebugLaunchRequestArguments = req.args;
        return try {
			final initBundleAttempt = new InitBundle(req, luadebug);
			Success(initBundleAttempt);
		} catch (e:InitBundleException) {
			Failure(e);
		}
    }
}
