package gmdebug.dap.clients;

import js.node.net.Socket;
class Client extends BaseConnected {

	public function new(fs:PipeSocket, clientID:Int) {
		super(fs,clientID);
	}
	
}


