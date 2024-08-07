package gmdebug.protocol.ext.messages;

typedef GmDebugMessage<T> = ProtocolMessage & {
	msg:GmMsgType<T>,
	body:T
}