package gmdebug.dap;

import js.node.Fs;
import haxe.io.Path;
import gmdebug.PromiseUtil;
import js.node.stream.Readable;
import js.node.Buffer;
import haxe.Timer;
import sys.FileSystem;
import js.node.ChildProcess;

using tink.CoreApi;
using StringTools;
using gmdebug.dap.PromiseUtil;

interface GmodClientOpener {
    public function open(server:GmodServerConnect,clientLoc:String,mrOptionsArr:Array<String>,requestClients:Int):PromiseArray<IReadable>;
}

class GmodClientOpenerSteam implements GmodClientOpener {

    public function open(server:GmodServerConnect,clientLoc:String,mroptions:Array<String>,requestClients:Int):PromiseArray<IReadable> {return null;}

}

final CLIENT_DASH_OPTIONS = "-multirun -condebug";

final CLIENT_PLUS_OPTIONS = "+sv_lan 1";

final CLIENT_EXE = "hl2.exe";

final CLIENT_IDLE = "client_idle_";

final CLIENT_ID_CONVAR = "gmdebug_id";

final CLIENT_CONSOLE = "console";

final EXT = ".log";


//KILL gmod clients when not using them anymore.
//return from open
class GmodClientOpenerMultirun implements GmodClientOpener {

    public function new() {}

    public function open(server:GmodServerConnect,clientLoc:String,mrOptionsArr:Array<String>,requestClients:Int):PromiseArray<IReadable> {
        final mrOptions = if (mrOptionsArr != null) {
            mrOptionsArr.join(" ");
        } else {
            "";
        }
        var idleClients = 0;
        for (i in 1...100) {
            if (!Fs.existsSync('$CLIENT_IDLE$i.dat')) break;
            idleClients++;
        }
        var spawnDiff = requestClients - idleClients;
        var pa = new PromiseArray();
        Fs.writeFileSync(haxe.io.Path.join([clientLoc,"connect.dat"]),'${server.ip}:${server.port}');
        for (i in 1...idleClients - 1) {
            pa.add(attachGmodClient(clientLoc,i));
        }
        for (i in idleClients...requestClients) {
            pa.add(spawnGmodClient(server,clientLoc,mrOptions,i));
        }
        return pa;
    }

    function spawnGmodClient(server:GmodServerConnect,clientLoc:String,mrOptions:String,id:Int):Promise<IReadable> { //when we're ready to spawn another one
        final pathToExe = haxe.io.Path.join([clientLoc,"..",CLIENT_EXE]);
        final pathToLinkClientConsole = haxe.io.Path.join([clientLoc,'$CLIENT_CONSOLE$EXT']);
        final pathToFinalClientConsole = haxe.io.Path.join([clientLoc,'${CLIENT_CONSOLE}_$id$EXT']);
        if (FileSystem.exists(pathToLinkClientConsole)) {
            Fs.unlinkSync(pathToLinkClientConsole);
        }
        if (FileSystem.exists(pathToFinalClientConsole)) {
            Fs.unlinkSync(pathToFinalClientConsole);
        }
        final cmd = 'mklink "$pathToLinkClientConsole" "$pathToFinalClientConsole"';
        trace(cmd);
        return sudoMkLink(cmd).next((_) -> {
            ChildProcess.spawn('"$pathToExe" $CLIENT_DASH_OPTIONS $mrOptions $CLIENT_PLUS_OPTIONS +connect ${server.ip}:${server.port} +$CLIENT_ID_CONVAR $id',{shell : true});
            return resolve(pathToFinalClientConsole,30000);
        });
    }

    function attachGmodClient(clientLoc:String,id:Int):Promise<IReadable> {
        final pathToFinalClientConsole = haxe.io.Path.join([clientLoc,'${CLIENT_CONSOLE}_$id$EXT']);
        return resolve(pathToFinalClientConsole,9999);
    }

    function sudoMkLink(cmd:String):Promise<Noise> {
        return ChildProcess.prom_exec(cmd).flatMap(function (outcome) {
            return switch (outcome) {
                case Failure({message : m}) if (m.contains("You do not have sufficient privilege to perform this operation")):
                    PromiseUtil.sudoExec(cmd);
                default:
                    (outcome : Promise<Dynamic>);
            }
        }).noise();
    }

    function resolve(file:String,timeout:Int):Promise<IReadable> {
        return new Promise(function (success,failure) {
            var timer = Timer.delay(() -> failure(new Error("gmodclientopener/resolve: Timed out...")),timeout);
            var watcher = null;
            var readable = new Readable();
            untyped readable._read = () -> {};
            var bytesReached = 0;
            var maxBuff = 256;
            var readonce = false;
            var interval = new Timer(100);
            interval.run = () -> {
                trace("Runnin");
                if (!Fs.existsSync(file)) return;
                trace("Interval!");
                interval.stop();
                var run:() -> Void;
                run = function() {
                    var buff = new Buffer(maxBuff);
                    var fd = Fs.openSync(file,null,null);
                    Fs.read(fd,buff,0,maxBuff,bytesReached,(err,bytesRead,buf) -> {
                        Fs.closeSync(fd);
                        haxe.Timer.delay(run,90);
                        var sliceBuff = buff.subarray(0,bytesRead);
                        if (bytesRead > 0) {
                            var push = untyped readable.push(sliceBuff);
                            bytesReached += bytesRead;
                            if (!push) bytesReached -= bytesRead;
                            trace('$bytesReached bytesReached');
                        }
                    });
                }
                haxe.Timer.delay(run,90);
                success(cast readable);
            };
            return () -> {interval.stop();};
        });
    }


}