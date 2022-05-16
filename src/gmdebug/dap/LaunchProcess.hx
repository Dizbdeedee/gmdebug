package gmdebug.dap;

import js.node.stream.Readable;
import js.node.stream.Writable;
import js.node.stream.Writable.IWritable;
import js.node.stream.Readable.IReadable;
import node.worker_threads.Worker;
import gmdebug.dap.srcds.RedirectWorker;
import ffi_napi.Library;
import js.Node;
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

	function attachOutput(luaDebug) {
		stdout.on(Data, (str:Buffer) -> {
			new ComposedEvent(output, {
				category: Stdout,
				output: str.toString().replace("\r", ""),
				data: null
			}).send(luaDebug);
		});
		stderr.on(Data, (str:Buffer) -> {
			new ComposedEvent(output, {
				category: Stdout,
				output: str.toString(),
				data: null
			}).send(luaDebug);
		});
	}

	function setupWindows(programPath,luaDebug,argString) {
		worker = RedirectWorker.makeWorker(programPath,[EXTRA_ARGS_WINDOWS,argString,EXTRA_ARGS]);
		worker.on("error", (err) -> {
			new ComposedEvent(output, {
				category: Stderr,
				output: err.message + "\n" + err.stack,
				data: null
			}).send(luaDebug);
			trace("Worker error///");
			trace(err.message);
			trace(err.stack);
			trace("Worker error end///");
			luaDebug.shutdown();
			return;
		});
		worker.on('exit', (_) -> {
			trace("Exit");
			luaDebug.shutdown();
			
		});
		worker.unref();
		stdin = cast worker.stdin;
		stdout = cast worker.stdout;
		stderr = cast worker.stderr;
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