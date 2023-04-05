package gmdebug;

#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end

import gmdebug.composer.RequestString;

enum ProtocolMessage {
    @:json({type : MessageType.Request, command : RequestString.launch}) 
    LaunchRequest(seq:Int,type:String,command:String,arguments:LaunchRequestArguments);
    @:json({type : MessageType.Request, command : RequestString.initialize}) 
    InitializeRequest(seq:Int,type:String,command:String,arguments:InitializeRequestArguments);
    @:json({type : MessageType.Request, command : RequestString.loadedSources}) 
    LoadedSourcesRequest(seq:Int,type:String,command:String,arguments:LoadedSourcesArguments);
    @:json({type : MessageType.Request, command : RequestString.stepIn}) 
    StepInRequest(seq:Int,type:String,command:String,arguments:StepInArguments);
    @:json({type : MessageType.Request, command : RequestString.stepOut}) 
    StepOutRequest(seq:Int,type:String,command:String,arguments:StepOutArguments);
    @:json({type : MessageType.Request, command : RequestString.next}) 
    NextRequest(seq:Int,type:String,command:String,arguments:NextRequestArguments);
    @:json({type : MessageType.Request, command : RequestString.pause}) 
    PauseRequest(seq:Int,type:String,command:String,arguments:PauseArguments);
    @:json({type : MessageType.Request, command : RequestString.gotoTargetsRequest}) 
    GotoTargetsRequ(seq:Int,type:String,command:String,arguments:GotoTargetsArguments);
    @:json({type : MessageType.Request, command : RequestString.variables}) 
    VariablesRequest(seq:Int,type:String,command:String,arguments:VariablesArguments);
    @:json({type : MessageType.Request, command : RequestString.scopes}) 
    ScopesRequest(seq:Int,type:String,command:String,arguments:ScopesArguments);
    @:json({type : MessageType.Request, command : RequestString._continue}) //wuh oh 
    ContinueRequest(seq:Int,type:String,command:String,arguments:ContinueArguments);
    @:json({type : MessageType.Request, command : RequestString.evaluate}) 
    EvaluateRequest(seq:Int,type:String,command:String,arguments:EvaluateArguments);
    @:json({type : MessageType.Request, command : RequestString.evaluate}) 

}


