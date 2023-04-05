package gmdebug.dap;

import js.node.ChildProcess;
import haxe.extern.Rest;
import js.node.Fs;
import js.node.util.Promisify;
using tink.CoreApi;


extern class PromiseUtil {
  
    public static extern inline function prom_open(cl:Class<Fs>,rest:Rest<Dynamic>):Promise<Dynamic> {
		return Promisify.promisify(Fs.open)(rest).toPromise();
	}
    
    public static extern inline function prom_exec(cl:Class<ChildProcess>,command:String,?options:ChildProcessExecOptions):Promise<Dynamic> {
        return Promisify.promisify(ChildProcess.exec)(command,options).toPromise();
    }
}