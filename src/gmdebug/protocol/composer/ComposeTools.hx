package gmdebug.protocol.composer;

import gmdebug.protocol.ext.GmDebugError;

class ComposeTools {
	/**
		Compose a response
		RequestString is not physically used, but ensures response is type checked
	**/
	public static function compose<X, Y>(req:Request<X>, str:RequestString<Request<X>, Response<Y>>,
			?body:Y):ComposedResponse<Null<Y>> {
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

	#if js
	public static function sendResp<X>(resp:Response<X>, luaDebug:gmdebug.dap.LuaDebugger) {
		luaDebug.sendResponse(cast resp);
	}
	#end
}
