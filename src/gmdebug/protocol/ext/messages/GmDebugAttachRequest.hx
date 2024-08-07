package gmdebug.protocol.ext.messages;

typedef GmDebugAttachRequestArguments = AttachRequestArguments & GmDebugBaseRequestArguments;

typedef GmDebugAttachRequest = Request<GmDebugAttachRequestArguments>;