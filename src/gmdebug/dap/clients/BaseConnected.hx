package gmdebug.dap.clients;

import tink.CoreApi;

//BaseDebugee
abstract class BaseConnected {
    
    final socket:PipeSocket;

	var threadID:Int;

	public final clID:Int;

	var disconnectActive = false;

	public var disconnectFuture:Future<Noise>;

	public function new(fs:PipeSocket,clID:Int) {
		socket = fs;
		this.clID = clID;
		disconnectFuture = fs.closeFuture;
	}

	public function sendRaw(x:String) {
		if (disconnectActive) return;
		socket.write(x);
	}

	public function disconnect() {
		disconnectActive = true;
		socket.end();
	}
}