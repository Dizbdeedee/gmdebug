package gmdebug.dap;

import gmdebug.Cross.PipeLocations;
import js.node.ChildProcess;
import js.node.Net;
import sys.FileSystem;
import js.node.Fs;
import js.node.util.Promisify;
import tink.CoreApi.Noise;
import js.node.net.Socket;
import gmdebug.lib.js.SudoPrompt;
using tink.CoreApi;
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

	static final CONNECT_ESTABLISH_DELAY = 15; //ms

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
		
		if (!isReady()) return Promise.reject(new Error('Client not ready yet...'));
		connStatus = CLIENT_NOT_ACK;
		sys.io.File.saveContent(locs.connection_in_progress,"");
		sys.io.File.saveContent(locs.connect,"");
		if (!isAck()) return Promise.reject(new Error("Client not acknowledging us..."));
		connStatus = MAKING_LINKS;
		trace("Client ready");
		return if (Sys.systemName() == "Windows") {
			aquireWindows();
		} else {
			aquireLinux();
		}
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
		return Future.irreversible(function (handler:Outcome<Noise,Error> -> Void) {
			std.SudoPrompt.exec(str,(err) -> 
				handler(if (err != null) {
					trace("Sudo-prompt failure...");
					Failure(tink.CoreApi.Error.ofJsError(err));
				} else {
					Success(Noise);
				})
			);
		});
	}


	function makeLinksWindows(args:MakeLinksWin):Promise<Noise> {
		final inpPath = js.node.Path.normalize(args.debugee_input);
		final outPath = js.node.Path.normalize(args.debugee_output);
		final cmd = 'mklink "$inpPath" "${args.pipe_input}" && mklink "$outPath" "${args.pipe_output}"';
		return if (!FileSystem.exists(inpPath) && !FileSystem.exists(outPath)) {
			try {
				ChildProcess.execSync(cmd);
				Noise;
			} catch (e) {
				if (e.message.contains("You do not have sufficient privilege to perform this operation")) {
					trace("Insufficient priveleges to make symbolic links. You can avoid this by switching to developer mode.");
					sudoExec(cmd);
				} else {
					trace("Cannot make windows links... Unhandled error");
					throw e;
				}
			}
		} else {
			Noise;
		}
		
	}

    @:async function aquireReadSocket(out:String) { //
		final open = Promisify.promisify(Fs.open);
		var fd = @:await open(out, cast Fs.constants.O_RDONLY | Fs.constants.O_NONBLOCK).toPromise();
		return new Socket({fd: fd, writable: false});
	}

	static function getValidSocket(server:js.node.net.Server):Future<Socket> {
		return Future.irreversible(function (handler:Socket -> Void) {
			server.on('connection',(socket:Socket) -> {
				trace("Connection!");
				var validSocket = true;
				socket.on('end',(err) -> {
					trace("Connection invalidated");
					validSocket = false;
				});
				haxe.Timer.delay(() -> {
					if (validSocket) {
						trace("Connection based");
						server.close();
						handler(socket);
					}
				},CONNECT_ESTABLISH_DELAY);
			});
		});
	}

	


	@:async function aquireWindowsSocket(serverIn:js.node.net.Server,serverOut:js.node.net.Server):{sockIn : Socket, sockOut : Socket} {
		trace("AquireWindowsSock");
		final socks = @:await Future.inParallel([getValidSocket(serverIn),getValidSocket(serverOut)]);
		//TODO on end, kill
		trace("We found the sock!");
		return {
			sockIn : socks[0],
			sockOut : socks[1]
		};
	}

	

	@:async function aquireWriteSocket(inp:String) {
		final open = Promisify.promisify(Fs.open);
		var fd = @:await open(inp, cast Fs.constants.O_RDWR | Fs.constants.O_NONBLOCK).toPromise();
		trace(fd);
		return new Socket({fd: fd, readable: false});
	}

    public function write(chunk:Dynamic) {
        writeS.write(chunk);
    }

    public function end() {
		
        readS.end();
        writeS.end();
		if (FileSystem.exists(locs.output)) {
			FileSystem.deleteFile(locs.output);
		}
		if (FileSystem.exists(locs.input)) {
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