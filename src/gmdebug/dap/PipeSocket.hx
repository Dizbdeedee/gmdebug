package gmdebug.dap;

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
	read:String, 
	write:String,
	ready:String,
	client_ready:String
}

	
typedef ReadFunc = (buf:js.node.Buffer) -> Void;

@:await
class PipeSocket {

	static final WIN_PIPE_NAME = "\\\\.\\pipe\\gmdebug";

    var writeS:Socket;

    var readS:Socket;

	final locs:PipeSocketLocations;
    
    var aquired:Bool = false;

    final readFunc:ReadFunc;

    //no async new functions
    public function new(locs:PipeSocketLocations,readFunc:ReadFunc) {
		this.locs = locs;
        this.readFunc = readFunc;
    }

	public function isReady() {
		trace("Checking readiness");
		return FileSystem.exists(locs.client_ready);
	}

    public function aquire():Promise<Noise> {
		if (!isReady()) throw "Client not ready yet...";
		trace("Client ready");
		return if (Sys.systemName() == "Windows") {
			aquireWindows();
		} else {
			aquireLinux();
		}
    }

	@:async public function aquireWindows() {
		trace("Waiting for windows socket");
		final server = Net.createServer();
		server.listen(WIN_PIPE_NAME);
		trace("Making links...");
		@:await makeLinksWindows(locs.read, locs.write).eager();
		sys.io.File.saveContent(locs.ready,"");
		readS = @:await aquireWindowsSocket(server);
		writeS = readS;
		writeS.write("\004\r\n");
		readS.on(Data,readFunc);
		aquired = true;
		return Noise;
	}

	@:async public function aquireLinux() {
		makeFifos(locs.read, locs.write);
        readS = @:await aquireReadSocket(locs.read); 
		writeS = @:await aquireWriteSocket(locs.write);
		sys.io.File.saveContent(locs.ready, "");
		writeS.write("\004\r\n");
		readS.on(Data,readFunc);
        aquired = true;
		trace("Aquired socket...");
		return Noise;
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
			std.SudoPrompt.exec(str,(err,_,_) -> {
				final result = if (err != null) {
					trace("Sudo-prompt failure...");
					Failure(tink.CoreApi.Error.ofJsError(err));
				} else {
					Success(Noise);
				}
				handler(result);
			});
		});
	}

	function makeLinksWindows(input:String,output:String):Promise<Noise> {
		final inpPath = js.node.Path.normalize(input);
		final outPath = js.node.Path.normalize(output);
		final cmd = 'mklink "$inpPath" "$WIN_PIPE_NAME" && mklink "$outPath" "$WIN_PIPE_NAME"';
		return if (!FileSystem.exists(inpPath) && !FileSystem.exists(outPath)) {
			try {
				ChildProcess.execSync(cmd);
				Noise;
			} catch (e) {
				if (e.message.contains("You do not have sufficient privilege to perform this operation")) {
					trace("Insufficient priveleges to make symbolic links. You can avoid this by switching to developer mode.");
					sudoExec(cmd);
				} else {
					trace(e);
					new Error("nani");
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

	static function getSocket(server:js.node.net.Server):Future<Socket> {
		return Future.irreversible(function (handler:Socket -> Void) {
			server.once('connection',(socket:Socket) -> {
				trace('Connection... ${socket}');
				socket.on('error',(err) -> {
					trace(err);
				});
				trace(untyped socket.readyState);
				handler(socket);
			});
		});
		
	}


	@:async function aquireWindowsSocket(server:js.node.net.Server) {
		var sock = @:await getSocket(server);
		trace("We found the sock!");
		return sock;
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
        FileSystem.deleteFile(locs.read);
		FileSystem.deleteFile(locs.write);
    }

}