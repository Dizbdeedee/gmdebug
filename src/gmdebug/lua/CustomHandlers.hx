package gmdebug.lua;

import gmdebug.lua.util.Util.isLan;
import gmdebug.composer.*;
import gmod.libs.GameLib;
import gmdebug.GmDebugMessage;
import gmod.Gmod;



class CustomHandlers {

    public function new() {}

    public function handle(x:GmDebugMessage<Dynamic>):CustomHandlersResponse {
        return switch (x.msg) {
            case clientID:
                h_clientID(cast x);
            case intialInfo:
                h_initalInfo(cast x);
            case playerAdded | playerRemoved | serverInfo:
                throw "Invalid customhandlers message";
            default:
                throw "Invalid customhandlers message";
        }
    }

    function h_clientID(x:GmDebugMessage<GMClientID>) {
        trace('recieved id ${x.body.id}');
        return CLIENT_ID(x.body.id);
    }

    function h_initalInfo(x:GmDebugMessage<GmDebugIntialInfo>) {
        return if (x.body.dapMode == Launch) { //previously send IP
            INITIAL_INFO(x.body.location,Launch);
        } else {
            INITIAL_INFO(x.body.location,Attach);
        }
    }
}

enum CustomHandlersResponse {
    CLIENT_ID(id:Int);
    INITIAL_INFO(dest:String,dapMode:DapModeStr);
}
