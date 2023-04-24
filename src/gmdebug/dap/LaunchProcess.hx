package gmdebug.dap;

import js.node.Fs;
import js.node.stream.Readable;
import js.node.stream.Writable;
import js.node.stream.Writable.IWritable;
import js.node.stream.Readable.IReadable;
import node.worker_threads.Worker;
import gmdebug.dap.srcds.RedirectWorker;
import ffi_napi.Library;
import js.Node;
import js.node.net.Socket;

import js.node.Buffer;
import gmdebug.composer.ComposedEvent;

using StringTools;

class LaunchProcess {
	
	static final EXTRA_ARGS = "+sv_lan 1 +sv_hibernate_think 1 +sv_allowcslua 1";
	
	static final EXTRA_ARGS_WINDOWS = "-console";

    var childProcess:js.node.child_process.ChildProcess;
	var worker:Worker;
	var stdout:IReadable;
	var stderr:IReadable;
	var stdin:IWritable;

	var luadebugwrite:IWritable;
	public var active(default,null) = true;

	var outputBufferBuf = 50;

	var outputBufferWait:Array<Event<Dynamic>> = [];

    public function new(programPath:String,luaDebug:LuaDebugger,?programArgs:Array<String>) {
        programArgs = programArgs.or([]);
		var argString = "";
		for (arg in programArgs) {
			argString += arg + " ";
		}
		if (Sys.systemName() == "Linux") {
			setupLinux(programPath,luaDebug,argString);	
		} else {
			setupWindows(programPath,luaDebug,argString);
		}
		
    }

	function setupLinux(programPath,luaDebug,argString) {
		childProcess = js.node.ChildProcess.spawn('script -c \'$programPath -norestart $argString +sv_lan 1 +sv_hibernate_think 1\' /dev/null', {
			cwd: haxe.io.Path.directory(programPath),
			env: Node.process.env,
			shell: true
		});
		stdin = childProcess.stdin;
		stdout = childProcess.stdout;
		stderr = childProcess.stderr;
		attachOutput(luaDebug);
		childProcess.on("error", (err) -> {
			new ComposedEvent(output, {
				category: Stderr,
				output: err.message + "\n" + err.stack,
				data: null
			}).send(luaDebug);
			trace("Child process error///");
			trace(err.message);
			trace(err.stack);
			trace("Child process error end///");
			luaDebug.shutdown();
			return;
		});
		
	}

	function attachOutput(luaDebug:LuaDebugger) {
		
		stdout.pipe(luadebugwrite,{end: false});
		// stdout.on('data',(buf:Buffer) -> {
		// 	logheader += buf.length;
		// });
		stderr.pipe(luadebugwrite,{end: false});
		// stdout.on(Data, (str:Buffer) -> {
		// 	if (luaDebug.shutdownActive) return;
		// 	new ComposedEvent(output, {
		// 		category: Stdout,
		// 		output: str.toString().replace("\r", ""),
		// 		data: null
		// 	}).send(luaDebug);
		// });
		
	}

	function setupWindows(programPath,luaDebug:LuaDebugger,argString) {
		childProcess = RedirectWorker.makeChildProcess(programPath,[EXTRA_ARGS_WINDOWS,argString,EXTRA_ARGS]);
		childProcess.on("error", (err) -> {
			active = false;
			new ComposedEvent(output, {
				category: Stderr,
				output: err.message + "\n" + err.stack,
				data: null
			}).send(luaDebug);
			trace("Child process error///");
			trace(err.message);
			trace(err.stack);
			trace("Child process error end///");
			luaDebug.shutdown();
			return;
		});
		childProcess.on("exit", (_) -> {
			active = false;
			trace("EXITED");
			luaDebug.shutdown();
		});
		luadebugwrite = new Writable({
			write : (chunk:Buffer, encoding, callback) -> {
				if (luaDebug.shutdownActive) return;
				new ComposedEvent(output, {
					category: Stdout,
					output: chunk.toString().replace("\r", ""),
					data: null
				}).send(luaDebug);
				callback(null);
			}
		});
		stdin = childProcess.stdin;
		stdout = childProcess.stdout;
		// // Fs.watchFile("C:\\Users\\g\\Documents\\gmodDS\\steamapps\\common\\GarrysModDS\\garrysmod\\console.log",{persistent : false},(_,_) -> {
		// // 	stdout = Fs.createReadStream("C:\\Users\\g\\Documents\\gmodDS\\steamapps\\common\\GarrysModDS\\garrysmod\\console.log",{start: logheader});
		// // 	attachOutput(luaDebug);

		// // });
		// stdout = Fs.createReadStream("C:\\Users\\g\\Documents\\gmodDS\\steamapps\\common\\GarrysModDS\\garrysmod\\console.log");
		// // stdout = new Socket({
		// // 	fd: Fs.openSync("C:\\Users\\g\\Documents\\gmodDS\\steamapps\\common\\GarrysModDS\\garrysmod\\console.log",cast Fs.constants.O_RDWR | Fs.constants.O_NONBLOCK),
		// // 	writable : false
		// // });
		// // stdout = 
		stderr = childProcess.stderr;
		attachOutput(luaDebug);
	}

    public function write(chunk:Dynamic) {
        stdin.write(chunk);
    }

    public function kill() {
		if (childProcess != null) {
			childProcess.kill();
		}
		if (worker != null) {
			worker.terminate();
		}
    }
}