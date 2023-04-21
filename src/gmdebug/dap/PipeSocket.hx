package gmdebug.dap;

import js.node.Fs;
import haxe.Timer;
import gmdebug.Cross.PipeLocations;
import js.node.ChildProcess;
import js.node.Net;
import sys.FileSystem;
import js.node.net.Socket;
using tink.CoreApi;
using gmdebug.dap.PromiseUtil;
using StringTools;

typedef PipeSocketLocations = {
    folder : String,
    aquired : String,
    debugee_output:String,
    debugee_input:String,
    ready:String,
    client_ready:String,
    client_ack:String
}


typedef ReadFunc = (buf:js.node.Buffer) -> Void;

private typedef MakeLinksWin = {
    debugee_input : String,
    debugee_output : String,
    pipe_input : String,
    pipe_output : String
}

enum ConnStatus {
    CLIENT_NOT_READY;
    CLIENT_NOT_ACK;
    MAKING_LINKS;

}

@:await
class PipeSocket {

    static final WATCH_FILE_TIMEOUT = 5;

    public var closeFuture:Future<Noise>;

    static final CONNECT_ESTABLISH_DELAY = 30; //ms

    static final WIN_PIPE_NAME_IN = "\\\\.\\pipe\\gmdebugin";

    static final WIN_PIPE_NAME_OUT = "\\\\.\\pipe\\gmdebugout";

    static var nextWinPipeNo = 0;

    var writeS:Socket;

    var readS:Socket;

    final locs:PipeLocations;

    var aquired:Bool = false;

    var readFunc:ReadFunc;

    var connStatus:ConnStatus = CLIENT_NOT_READY;


    //no async new functions
    public function new(locs:PipeLocations) {
        this.locs = locs;

    }

    public function isReady() {
        trace("Checking readiness");
        return connStatus != CLIENT_NOT_READY || FileSystem.exists(locs.client_ready);
    }

    public function isAck() {
        trace("Checking ack...");
        return connStatus != CLIENT_NOT_ACK || FileSystem.exists(locs.client_ack);
    }

    public function aquire():Promise<PipeSocket> {
        return resolveReadiness(WATCH_FILE_TIMEOUT * 1000).next(_ -> {
            connStatus = CLIENT_NOT_ACK;
            Fs.writeFileSync(locs.connect,"");
            return resolveAck(WATCH_FILE_TIMEOUT * 1000).next(_ -> {
                connStatus = MAKING_LINKS;
                return if (Sys.systemName() == "Windows") {
                    aquireWindows();
                } else {
                    aquireLinux();
                }
            });
        });
    }


    function resolveReadiness(timeout:Int) {
        return new Promise(function (success,failure) {
            var timer = Timer.delay(() -> failure(new Error("Timed out...")),timeout);
            var watcher = null;
            if (isReady()) {
                if (watcher != null) {
                    watcher.close();
                }
                timer.stop();
                success(Noise);
                return () -> {};
            }
            var watcher = Fs.watch(locs.folder,{persistent : false},(_,_) -> {
                if (isReady()) {
                    watcher.close();
                    timer.stop();
                    success(Noise);
                }
            });
            return () -> {
                watcher.close();
                timer.stop();
            };
        });
    }

    function resolveAck(timeout:Int) {
        return new Promise(function (success,failure) {
            var timer = Timer.delay(() -> failure(new Error("Timed out...")),timeout);
            var watcher = null;
            if (isAck()) {
                // watcher.close();
                if (watcher != null) {
                    watcher.close();
                }
                timer.stop();
                success(Noise);
                return () -> {};
            }
            watcher = Fs.watch(locs.folder,{persistent : false},(_,_) -> {
                if (isAck()) {
                    watcher.close();
                    timer.stop();
                    success(Noise);
                }
            });
            return () -> {
                watcher.close();
                timer.stop();
            };
        });
    }

    public function assignRead(_readFunc:ReadFunc) {
        readS.on(Data,_readFunc);
        readFunc = _readFunc;
    }

    public function beginConnection() {
        writeS.write("\004\r\n");
        aquired = true;
    }

    @:async public function aquireWindows() {
        trace("Waiting for windows socket");
        trace(locs);
        final pipeNo = nextWinPipeNo++;
        final serverIn = Net.createServer();
        final pipeInName = '$WIN_PIPE_NAME_IN$pipeNo';
        serverIn.listen(pipeInName);
        final serverOut = Net.createServer();
        final pipeOutName = '$WIN_PIPE_NAME_OUT$pipeNo';
        serverOut.listen(pipeOutName);
        trace("Making links...");
        @:await makeLinksWindows({
            debugee_input :	locs.input,
            debugee_output : locs.output,
            pipe_input : pipeInName,
            pipe_output : pipeOutName
        }).eager();
        sys.io.File.saveContent(locs.pipes_ready,"");
        final sockets = @:await aquireWindowsSocket(serverIn,serverOut);
        trace("Servers created");
        writeS = sockets.sockIn;
        readS = sockets.sockOut;
        return this;
    }

    @:async public function aquireLinux() {
        makeFifos(locs.input, locs.output);
        sys.io.File.saveContent(locs.pipes_ready,"");
        readS = @:await aquireReadSocket(locs.output);
        writeS = @:await aquireWriteSocket(locs.input);
        writeS.write("\004\r\n");
        // readS.on(Data,readFunc);
        aquired = true;
        trace("Aquired socket...");
        return this;
    }

    function makeFifos(input:String, output:String) {

        if (!FileSystem.exists(input) && !FileSystem.exists(output)) {
            js.node.ChildProcess.execSync('mkfifo $input');
            js.node.ChildProcess.execSync('mkfifo $output');
            Fs.chmodSync(input, "744");
            Fs.chmodSync(output, "722");
        };
    }

    static function sudoExec(str:String):Promise<Noise> {
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



    function makeLinksWindows(args:MakeLinksWin):Promise<Noise> {
        final inpPath = js.node.Path.normalize(args.debugee_input);
        final outPath = js.node.Path.normalize(args.debugee_output);
        final cmd = 'mklink "$inpPath" "${args.pipe_input}" && mklink "$outPath" "${args.pipe_output}"';
        return if (!FileSystem.exists(inpPath) && !FileSystem.exists(outPath)) {
            ChildProcess.prom_exec(cmd).flatMap(function (outcome) {
                return switch (outcome) {
                    case Failure({message : m}) if (m.contains("You do not have sufficient privilege to perform this operation")):
                        sudoExec(cmd);
                    default:
                        (outcome : Promise<Dynamic>);
            }}).noise();
            // Promise.NOISE;
        } else {
            Promise.NOISE;
        }

    }

    @:async function aquireReadSocket(out:String) { //
        var fd = @:await Fs.prom_open(out, cast Fs.constants.O_RDONLY | Fs.constants.O_NONBLOCK);
        return new Socket({fd: fd, writable: false});
    }

    //ignorance: probing the file details, or checking it exists counts as opening and closing the file
    //we try and avoid invalid connections by waiting to see if they instantly close
    function getValidSocket(server:js.node.net.Server):Promise<Socket> {
        return new Promise(function (success,failure) {
            trace("getValidSocket");
            var socketsStatus:Array<Socket> = [];
            haxe.Timer.delay(() -> {
                trace(socketsStatus);
                
                for (socket in socketsStatus) {
                    if (socket != null) {
                        server.close();
                        socket.removeAllListeners(End);
                        success(socket);
                        return;
                    }
                }
                failure(new Error("Timeout for connection"));
                // }
            },500);
            server.on('connection',(socket:Socket) -> {
                var id = socketsStatus.length;
                var invalidateSocket = () -> {
                    socketsStatus[id] = null;
                };
                socketsStatus.push(socket);
                socket.on(End,invalidateSocket);
                // if (!ranConnection) {
                //     // haxe.Timer.delay(() -> {

                //     // },2500);
                // }
                // ranConnection = true;
                // trace("Connection!");
                // var validSocket = true;
                

                // haxe.Timer.delay(() -> {
                //     if (validSocket) {
                //         server.close();
                //         socket.off(End,invalidateSocket);
                //         success(socket);
                //     } else {
                        
                //         trace("What are you trying to prove?");
                //     }
                // },CONNECT_ESTABLISH_DELAY);
            });
            return function () {
                // server.off('connection');
                server.close();
            };

        });
    }

    @:async function aquireWindowsSocket(serverIn:js.node.net.Server,serverOut:js.node.net.Server):{sockIn : Socket, sockOut : Socket} {
        trace("AquireWindowsSock");
        final socks = @:await Promise.inParallel([getValidSocket(serverIn),getValidSocket(serverOut)]);

        //TODO on end, kill
        trace("We found the sock!");
        closeFuture = Future.irreversible(function (trigger:Noise -> Void) {
            socks[0].on(End,() -> {
                trigger(Noise);
            });
            socks[1].on(End,() -> {
                trigger(Noise);
            });
        });
        return {
            sockIn : socks[0],
            sockOut : socks[1]
        };
    }



    @:async function aquireWriteSocket(inp:String) {
        var fd = @:await Fs.prom_open(inp, cast Fs.constants.O_RDWR | Fs.constants.O_NONBLOCK);
        trace(fd);
        return new Socket({fd: fd, readable: false});
    }

    public function write(chunk:Dynamic) {
        writeS.write(chunk);
    }

    public function end() {

        if (FileSystem.exists(locs.output)) {
            readS.end();
            FileSystem.deleteFile(locs.output);
        }
        if (FileSystem.exists(locs.input)) {
            writeS.end();
            FileSystem.deleteFile(locs.input);
        }
        if (FileSystem.exists(locs.connect)) {
            FileSystem.deleteFile(locs.connect);
        }
        if (FileSystem.exists(locs.client_ack)) {
            FileSystem.deleteFile(locs.client_ack);
        }
        if (FileSystem.exists(locs.client_ready)) {
            FileSystem.deleteFile(locs.client_ready);
        }
        if (FileSystem.exists(locs.pipes_ready)) {
            FileSystem.deleteFile(locs.pipes_ready);
        }
        FileSystem.deleteDirectory(locs.folder);

    }

}
