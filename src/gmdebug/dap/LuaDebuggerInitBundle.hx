package gmdebug.dap;

import gmdebug.dap.clients.ClientStorage;
import gmdebug.dap.InitializedDebugger;

typedef LuaDebuggerInitBundle = {
    bytesProcessor : BytesProcessor,
    prevRequests : PreviousRequests,
    clients : ClientStorage,
    requestRouter : RequestRouter,
    eventIntercepter : EventIntercepter,
    responseIntercepter : ResponseIntercepter,
    initalizedDebuggerFactory : () -> InitializedDebugger
}