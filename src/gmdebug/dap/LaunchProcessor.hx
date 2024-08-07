package gmdebug.dap;

import js.node.child_process.ChildProcess;
import js.Node;
import gmdebug.dap.srcds.RedirectWorker;

using tink.CoreApi;

interface LaunchProcessor {
	function launchLinux(lp:LaunchProperties):Option<ChildProcess>;

	function launchWindows(lp:LaunchProperties):Option<ChildProcess>;

	function createLP(ib:InitBundle):LaunchProperties;
}

class LaunchProcessorDef implements LaunchProcessor {
	static final EXTRA_ARGS = "+sv_hibernate_think 1 +sv_allowcslua 1";

	static final EXTRA_ARGS_WINDOWS = "-console";

	static final EXTRA_ARGS_LINUX = "-norestart";

	static final ARG_PORT = "-port";

	static final ARG_MAP = "-map";

	static final ARG_GAMEMODE = "-gamemode";


	public function new() {}

	// way behind... and not updated
	public function launchLinux(lp:LaunchProperties):Option<ChildProcess> {
		var childProcess = js.node.ChildProcess.spawn('script -c \'${lp.programPath} ${lp.preArg} $EXTRA_ARGS_LINUX ${lp.postArg}\' /dev/null',
			{
				cwd: haxe.io.Path.directory(lp.programPath),
				env: Node.process.env,
				shell: true
			});
		return Some(childProcess);
	}

	public function launchWindows(lp:LaunchProperties):Option<ChildProcess> {
		var childProcess = RedirectWorker.makeChildProcess(lp.programPath
			, [lp.preArg, EXTRA_ARGS_WINDOWS, lp.postArg]);
		return Some(childProcess);
	}

	public function createLP(ib:InitBundle):LaunchProperties {
		var programPath = ib.programPath;
		var preArg = '$ARG_PORT ${ib.serverPort} $ARG_GAMEMODE ${ib.gamemode}';
		var postArg = '${ib.argString} $ARG_MAP ${ib.map} $EXTRA_ARGS';
		return {programPath: programPath, preArg: preArg, postArg: postArg};
	}
}

typedef LaunchProperties = {
	programPath:String,
	preArg:String,
	postArg:String,
}