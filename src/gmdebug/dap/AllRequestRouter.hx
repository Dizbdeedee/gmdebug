package gmdebug.dap;

import gmdebug.dap.clients.ClientStorage;

class AllRequestRouter implements RequestRouter {
    
    final clients:ClientStorage;

    final luaDebug:InitializedDebugger;

    public function new(_clients:ClientStorage,_luaDebug:InitalizedDebugger) {
        clients = _clients;
        luaDebug = _luaDebug;
    }

    public function route(req:Request<Dynamic>) {
        final command:AnyRequest = req.command;
        switch (command) {
            case pause | stackTrace | stepIn | stepOut | next | "continue":
                final id = (req : HasThreadID).arguments.threadId;
                clients.sendAny(id, req);
            case disconnect:
                trace("disconnect");
                h_disconnect(req);
            case scopes:
                h_scopes(req);
            case variables:
                h_variables(req);
            case evaluate:
                h_evaluate(req);
            case setBreakpoints:
                h_setBreakpoints(req);                
            case setExceptionBreakpoints:
                prevRequests.update(req);
                clients.sendAll(req);
            case setFunctionBreakpoints:
                prevRequests.update(req);
                clients.sendAll(req);
            case initialize:
                h_initialize(req);
            case configurationDone:
                clients.sendServer(req);
            case threads:
                h_threads(req);
            case loadedSources | modules | goto | gotoTargets | breakpointLocations | _continue: // _continue: ARRRRGGGHHHH
                clients.sendServer(req);
        }
    }

    function h_threads(req:ThreadsRequest) {
        final threadArr = [{name: "Server", id: 0}];
        for (id => cl in clients.getClients()) { //hmm...
            if (id == 0) continue;
            threadArr.push({
                name : 'Client ${cl.clID}',
                id : cl.clID
            });
            trace(cl.clID);
        }
        trace(threadArr);
        req.compose(threads, {threads: threadArr}).send(luaDebug);
    }

    function h_disconnect(req:DisconnectRequest) {
        clients.sendAll(req);
        req.compose(disconnect).send(luaDebug);
        luaDebug.shutdown();
    }

    function h_variables(req:VariablesRequest) {
        final ref:VariableReference = req.arguments.variablesReference;
        if ((ref : Int) <= 0) {
            trace("invalid variable reference");
            req.compose(variables, {variables: []}).send(luaDebug);
            return;
        }
        switch (ref.getValue()) {
            case Global(clID, _) | FrameLocal(clID, _, _) | Child(clID, _):
                clients.sendAny(clID, req);
            case INVALID:
                trace("Where the hell are we going to send you?");
                req.compose(variables, {variables: []}).send(luaDebug);
        }
    }

    function h_evaluate(req:EvaluateRequest) {
        final expr = req.arguments.expression;
        if (expr.charAt(0) == "/") {
            switch (luaDebug.dapMode) {
                case LAUNCH(child):
                    final actual = expr.substr(1);
                    child.write(actual + "\n");
                    req.compose(evaluate, {
                        result: "",
                        variablesReference: 0
                    }).send(luaDebug);
                    return;
                default:
            }
        }
        final client = switch (req.arguments.frameId) {
            case null:
                0; // run as server if not in frame context. might cause issues...
            case frame:
                (frame : FrameID).getValue().clientID;
        }
        clients.sendAny(client, req);
    }

    // function createDirArray(dir:String) {
    //     var curStr = dir;
    //     var cumArray = [];
    //     while (curStr != null) {
    //         curStr = HxPath.directory(curStr);
    //         cumArray.push(HxPath.withoutDirectory(curStr));
    //     }
    //     return cumArray;
    // }

    // //i would rather just make SOMETHING at this point... goddamn
    // function matchPath(path:Array<String>,find:Array<String>) {
    //     for (ipath => _ in path) {
    //         var match = true;
    //         for (ufind => val in find) {
    //             if (path[ipath + ufind] != val) {
    //                 match = false;
    //                 break;
    //             }
    //         }
    //         if (match) {
    //             return true;
    //         }
    //     }
    //     return false;
    // }

    static final luaPaths = ["garrysmod","lua"];

    static final addonPath = ["garrysmod","addons"];

    function h_setBreakpoints(req:SetBreakpointsRequest) {
        final path = js.node.Path.normalize(req.arguments.source.path);
        final matchServer = luaDebug.initBundle.serverFolder;
        req.arguments.source.path = pathManager.realPathToGmodPath(req.arguments.source.path);
        if (path.contains(matchServer)) {
            trace("mathc server");
            clients.sendServer(req);
        }
        var clientLocation = luaDebug.initBundle.clientLocation;
        if (clientLocation != null) {
            if (path.contains(clientLocation)) {
                trace("match client");
                for (i in 1...clients.getClients().length) {
                    clients.sendAny(i,req);
                }
            }
        }
        
        // clients.sendAll(req);
    }

    function h_scopes(req:ScopesRequest) {
        final client = (req.arguments.frameId : FrameID).getValue().clientID; // mandatory
        clients.sendAny(client, req);
    }
}