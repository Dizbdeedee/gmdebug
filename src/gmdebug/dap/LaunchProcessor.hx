package gmdebug.dap;

import js.node.child_process.ChildProcess;
import js.Node;
import gmdebug.dap.srcds.RedirectWorker;

using tink.CoreApi;

interface LaunchProcessor {
	function launchLinux(programPath:String, argString:String, port:String):Option<ChildProcess>;

	function launchWindows(programPath:String, argString:String, port:String):Option<ChildProcess>;
}

class LaunchProcessorDef implements LaunchProcessor {
	static final EXTRA_ARGS = "+sv_lan 1 +sv_hibernate_think 1 +sv_allowcslua 1";

	static final EXTRA_ARGS_WINDOWS = "-console";

	static final ARG_PORT = "-port";

	public function new() {}

	// way behind... and not updated
	public function launchLinux(programPath:String, argString:String, port:String):Option<ChildProcess> {
		var childProcess = js.node.ChildProcess.spawn('script -c \'$programPath -norestart $argString $EXTRA_ARGS\' /dev/null',
			{
				cwd: haxe.io.Path.directory(programPath),
				env: Node.process.env,
				shell: true
			});
		return Some(childProcess);
	}

	public function launchWindows(programPath:String, argString:String, port:String):Option<ChildProcess> {
		var childProcess = RedirectWorker.makeChildProcess(programPath
			, [EXTRA_ARGS_WINDOWS, ARG_PORT, port, argString, EXTRA_ARGS]);
		return Some(childProcess);
	}
}
