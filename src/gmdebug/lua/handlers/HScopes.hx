package gmdebug.lua.handlers;

import gmod.libs.DebugLib;


typedef InitHScopes = {
	debugee : Debugee
}
class HScopes implements IHandler<ScopesRequest> {
	
	final debugee:Debugee;

	public function new(init:InitHScopes) {
		debugee = init.debugee;
	}

	public function handle(scopeReq:ScopesRequest):HandlerResponse {
		var args = scopeReq.arguments.sure();
		final frameInfo = (args.frameId : FrameID).getValue();
		var info = DebugLib.getinfo(StackHeightCounter.getRSS() + frameInfo.actualFrame, "fuS");
		var arguments:Scope = {
			name: "Arguments",
			presentationHint: Arguments,
			variablesReference: VariableReference.encode(FrameLocal(debugee.clientID, frameInfo.actualFrame, Arguments)),
			expensive: false
		}
		var locals:Scope = switch (info) {
			case null:
				null;
			case {linedefined : null, lastlinedefined : null}:
				{
					name: "Locals",
					presentationHint: Locals,
					variablesReference: VariableReference.encode(FrameLocal(debugee.clientID, frameInfo.actualFrame, Locals)),
					expensive: false,
				};
			case {linedefined : ld, lastlinedefined : lld}:
				{
					name: "Locals",
					presentationHint: Locals,
					variablesReference: VariableReference.encode(FrameLocal(debugee.clientID, frameInfo.actualFrame, Locals)),
					expensive: false,
					line: ld,
					endLine: lld,
					column: 1,
					endColumn: 99999
				};
		};
		
		var upvalues:Scope = {
			name: "Upvalues",
			variablesReference: VariableReference.encode(FrameLocal(debugee.clientID, frameInfo.actualFrame, Upvalues)),
			expensive: false,
		};
		var globals:Scope = {
			name: "Globals",
			variablesReference: VariableReference.encode(Global(debugee.clientID, Globals)),
			expensive: true,
		}
		var players:Scope = {
			name: "Players",
			variablesReference: VariableReference.encode(Global(debugee.clientID, Players)),
			expensive: true
		}
		var entities:Scope = {
			name: "Entities",
			variablesReference: VariableReference.encode(Global(debugee.clientID, Entities)),
			expensive: true,
		}
		var enums:Scope = {
			name: "Enums",
			variablesReference: VariableReference.encode(Global(debugee.clientID, Enums)),
			expensive: true
		}

		var env:Scope = {
			name: "Function Environment",
			variablesReference: VariableReference.encode(FrameLocal(debugee.clientID, frameInfo.actualFrame, Fenv)),
			expensive: true
		}
		var hasFenv:Bool = if (info != null && info.func != null) {
			final func = info.func;
			DebugLib.getfenv(func) != untyped __lua__("_G");
		} else {
			false;
		}
		var resp = scopeReq.compose(scopes, {
			scopes: switch info {
				case null:
					Lua.print("No info?!", frameInfo.actualFrame);
					[globals, entities, players, enums];
				case {what : C}:
					[arguments, locals, globals, entities, players, enums];
				case {what : Lua}:
					if (hasFenv) {
						[arguments, locals, upvalues, env, globals, entities, players, enums];
					} else {
						[arguments, locals, upvalues, globals, entities, players, enums];
					}
				case {what : main}:
					[locals, upvalues, env, globals, entities, players, enums];
				default:
					Lua.print("OH GOD",info.what);
					[globals, entities, players, enums];
			}
		});
		final js = tink.Json.stringify((cast resp : ScopesResponse)); // in pratical terms they're the same
		debugee.send(js);
		return WAIT;
	}
}




