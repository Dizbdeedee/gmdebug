package gmdebug.dap;

import haxe.io.Path;
import gmdebug.Util.recurseCopy;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import gmdebug.composer.RequestString;
import js.Node;
import js.node.Buffer;
import js.node.child_process.ChildProcess;
import js.node.fs.Stats;
import js.node.Fs;
import gmdebug.composer.*;
import vscode.debugProtocol.DebugProtocol;
import gmdebug.VariableReference;
import gmdebug.GmDebugMessage;
import gmdebug.dap.clients.ClientStorage;
import haxe.io.Path as HxPath;
using gmdebug.composer.ComposeTools;
using Lambda;
using Safety;
using StringTools;

interface RequestRouter {
    public function route(req:Request<Dynamic>):Void;
}

class RequestRouterInit {

    final luaDebug:LuaDebugger;

    final onInit:(req:GmDebugLaunchRequest) -> Void; 

    public function new(luaDebug:LuaDebugger,onInit:(req:GmDebugLaunchRequest) -> Void) {
        this.luaDebug = luaDebug;
        this.onInit = onInit;
    }

    public function route(req:Request<Dynamic>) {
        final command:AnyRequest = req.command;
        switch (command) {
            case attach:
                h_attach(req);
            case disconnect:
                trace("disconnect");
                h_disconnect(req);
            case launch:
                h_launch(req);     
            case initialize:
                h_initialize(req);
        }
    }

    function h_disconnect(req:DisconnectRequest) {
        // clients.sendAll(req);
        req.compose(disconnect).send(luaDebug);
        luaDebug.shutdown();
    }


    function h_initialize(req:InitializeRequest) {
        final response:InitializeResponse = {
            seq: 0, // it gets ignored anyway
            request_seq: req.seq,
            command: "initialize",
            type: Response,
            body: {},
            success: true,
        }
        response.body.supportsConfigurationDoneRequest = true;
        response.body.supportsFunctionBreakpoints = true;
        response.body.supportsConditionalBreakpoints = true;
        response.body.supportsEvaluateForHovers = true;
        response.body.supportsLoadedSourcesRequest = true;
        response.body.supportsFunctionBreakpoints = true;
        response.body.supportsDelayedStackTraceLoading = false;
        response.body.supportsBreakpointLocationsRequest = false;
        untyped response.body.supportsSingleThreadExecutionRequests = true;
        luaDebug.sendResponse(response);
    }

    function h_launch(req:GmDebugLaunchRequest) {
        onInit(req);
        // luaDebug.initFromRequest(req,req.arguments);
    }

    function h_attach(req:GmDebugAttachRequest) {
        req.composeFail(DEBUGGER_NO_ATTACH)
        .send(luaDebug);
        return;
    }

}

private typedef HasThreadID = {
    arguments:{
        threadId:Int
    }
}
