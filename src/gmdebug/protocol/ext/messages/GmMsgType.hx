package gmdebug.protocol.ext.messages;

import gmdebug.protocol.ext.messages.GmDebugInitialInfo;

enum abstract GmMsgType<T>(Int) to Int {
	var playerAdded:GmMsgType<GMPlayerAddedMessage>;
	var playerRemoved:GmMsgType<GMPlayerRemovedMessage>;
	var clientID:GmMsgType<GMClientID>;
	var intialInfo:GmMsgType<GmDebugInitialInfo>;
	var serverInfo:GmMsgType<GMServerInfoMessage>;
}
