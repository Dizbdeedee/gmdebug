package gmdebug.dap;

import js.node.child_process.ChildProcess;


interface LaunchProcessor {

    function launchLinux(programPath:String,?programArgs:Array<String>):Option<ChildProcess>;

    function launchWindows(programPath:String,?programArgs:Array<String>):Option<ChildProcess>;

}


class LaunchProcessorDef {

    static final EXTRA_ARGS = "+sv_lan 1 +sv_hibernate_think 1 +sv_allowcslua 1";

    static final EXTRA_ARGS_WINDOWS = "-console";

    public function new () {}

    public function launchLinux(programPath:String,?programArgs:Array<String>):ChildProcess {
        programArgs = programArgs.or([]);
        var argString = "";
        for (arg in programArgs) {
            argString += arg + " ";
        }
        var childProcess = js.node.ChildProcess.spawn('script -c \'$programPath -norestart $argString $EXTRA_ARGS\' /dev/null', {
            cwd: haxe.io.Path.directory(programPath),
            env: Node.process.env,
            shell: true
        });
        return Some(childProcess);
        // childProcess.on("error", (err) -> {
        //     new ComposedEvent(output, {
        //         category: Stderr,
        //         output: err.message + "\n" + err.stack,
        //         data: null
        //     }).send(luaDebug);
        //     trace("Child process error///");
        //     trace(err.message);
        //     trace(err.stack);
        //     trace("Child process error end///");
        //     luaDebug.shutdown();
        //     return;
        // });
    }

    public function launchWindows(programPath:String,?programArgs:Array<String>) {
        programArgs = programArgs.or([]);
        var argString = "";
        for (arg in programArgs) {
            argString += arg + " ";
        }
        var childProcess = RedirectWorker.makeChildProcess(programPath,[EXTRA_ARGS_WINDOWS,argString,EXTRA_ARGS]);
        return Some(childProcess);
        // childProcess.on("error", (err) -> {
        //     active = false;
        //     new ComposedEvent(output, {
        //         category: Stderr,
        //         output: err.message + "\n" + err.stack,
        //         data: null
        //     }).send(luaDebug);
        //     trace("Child process error///");
        //     trace(err.message);
        //     trace(err.stack);
        //     trace("Child process error end///");
        //     luaDebug.shutdown();
        //     return;
        // });
        // childProcess.on("exit", (_) -> {
        //     active = false;
        //     trace("EXITED");
        //     luaDebug.shutdown();
        // });
    }
}