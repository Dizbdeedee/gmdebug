package gmdebug.composer;

import haxe.DynamicAccess;
import gmdebug.GmDebugError.GMDEBUG_ERROR_STRINGS;
#if lua
import gmdebug.lib.lua.Protocol;
#elseif js
import vscode.debugProtocol.DebugProtocol;
#end

class ComposeTools {
	/**
		Compose a response
		RequestString is not physically used, but ensures response is type checked
	**/
	public static function compose<X, Y>(req:Request<X>, str:RequestString<Request<X>, Response<Y>>,
			?body:Y):ComposedResponse<Null<Y>> {
		// return ;
		var response = new ComposedResponse(req, body);
		response.success = true;
		return response;
	}

	public static function _composeFail<X, Y>(req:Request<X>,
			?error:Message):ComposedResponse<Null<Message>> {
		var response = new ComposedResponse(req, error);
		response.message = error.format;

		response.success = false;
		return response;
	}

	public static function composeFail<X, Y>(req:Request<X>, id:GmDebugError,
			?variables:{}):ComposedResponse<Null<Message>> {
		var error:Message = {
			id: id,
			showUser: true,
			variables: variables,
			format: GMDEBUG_ERROR_STRINGS.get(id),
		}
		var response = new ComposedResponse(req, error);
		response.message = error.format;
		response.success = false;
		return response;
	}
}
