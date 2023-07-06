package gmdebug.dap;

import js.node.ChildProcess;
import haxe.extern.Rest;
import js.node.Fs;
import js.node.util.Promisify;
using tink.CoreApi;

//NO
extern class PromiseUtil {

    public static extern inline function prom_open(cl:Class<Fs>,rest:Rest<Dynamic>):Promise<Dynamic> {
        return Promisify.promisify(Fs.open)(rest).toPromise();
    }

    public static extern inline function prom_exec(cl:Class<ChildProcess>,command:String,?options:ChildProcessExecOptions):Promise<Dynamic> {
        return Promisify.promisify(ChildProcess.exec)(command,options).toPromise();
    }

    public static function sudoExec(str:String):Promise<Noise> {
        return new Promise(function (success,failure) {
            std.SudoPrompt.exec(str,(err) -> {
            if (err != null) {
                trace("Sudo-prompt failure...");
                failure(tink.CoreApi.Error.ofJsError(err));
            } else {
                success(Noise);
            }});
            return null; //noop
        });
    }
}