package gmdebug.dap.clients;

import js.node.net.Socket;

class Client extends BaseConnected {
	var name:String;

	public function new(fs:PipeSocket, clientID:Int) {
		super(fs, clientID);
	}
}
