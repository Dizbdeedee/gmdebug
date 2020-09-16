package gmdebug;

import haxe.display.Protocol.InitializeParams;
import haxe.io.BytesData;
import haxe.io.Bytes;
import tink.CoreApi.Ref;
#if lua 
import gmdebug.lua.Protocol.ProtocolMessage;
#elseif js
import vscode.debugProtocol.DebugProtocol.ProtocolMessage;
#end
import gmdebug.VariableReference;
import haxe.Json;
import haxe.io.Input;
class Cross {

    public static final FOLDER = "gmdebug";

    public static final INPUT = haxe.io.Path.join([FOLDER,"in.dat"]);

    public static final OUTPUT = haxe.io.Path.join([FOLDER,"out.dat"]);

    public static final READY = haxe.io.Path.join([FOLDER,"ready.dat"]);

    public static final CHECK = haxe.io.Path.join([FOLDER,"check.dat"]);

    public static final DATA = "data";

    public static final JIT = haxe.io.Path.join([FOLDER,"jitchoice.txt"]);

    @:nullSafety(Off)
    public static function readHeader(x:Input) {
        var content_length = x.readLine();
        var skip = 0;
        var onlySkipped = true;
        for (i in 0...content_length.length) {
            if (content_length.charCodeAt(i) == 4) {
                skip++;
            } else {
                onlySkipped = false;
                break;
            }
        }
        #if lua
        if (onlySkipped) { //only happens on lua
            return null;
        }
        #end
        if (skip > 0) {
            //skipped x
            content_length = content_length.substr(skip);
        }
        var content_length = Std.parseInt(@:nullSafety(Off) content_length.substr(15));
        x.readLine();
        return content_length;
    }



    @:nullSafety(Off) public static function recvMessage(x:Input):MessageResult {
        var len = readHeader(x);
        if (len == null) {
            return ACK;
        }
        var dyn = x.readString(len,UTF8); //argh
        return MESSAGE(Json.parse(dyn));
    }
   
}





enum abstract ComMethod(String) {
    var pipe;
    var socket;
}
    
enum CommMethod {
    Pipe;
    Socket;
}

enum MessageResult {
    ACK;
    MESSAGE(x:Dynamic);
}

enum abstract ExceptionBreakpointFilters(String) to String {
    //var all
    var gamemode;
    var entities;
}


typedef GmDebugMessage<T> = ProtocolMessage & {
    // type : String,
    msg : GmMsgType<T>,
    body : T
}




enum abstract GmMsgType<T>(Int) to Int {

    var playerAdded:GmMsgType<GMPlayerAddedMessage>;

    var playerRemoved:GmMsgType<GMPlayerRemovedMessage>;

    var clientID:GmMsgType<GMClientID>;

    var intialInfo:GmMsgType<GmDebugIntialInfo>;
}

typedef GmDebugIntialInfo = {

    /**
       Location. Can be server or client.
    **/
    location:String

}

typedef GMPlayerAddedMessage = {
    /** ID of client. **/
    playerID : Int,
    /** name of client **/
    name : String
}

typedef GMPlayerRemovedMessage = {
    /** ID of client **/
    playerID : Int
}

typedef GMClientID = {
    /**
	Your thread number given
    **/
    id : Int
}

// public static final maxLocalScopes = 128;

// public static final maxGlobalScopes = 128;

// public static final maxFrames = 128;

// public static final maxClients = 16;

// public static final maxVariables = 2^25;