package ffi_napi;

/**
	Turns a JavaScript function into a C function pointer.
	The function pointer may be used in other C functions that
	accept C callback functions.
**/
@:jsRequire("ffi-napi", "Callback") extern class Callback {
	@:overload(function(retType:ts.AnyOf2<String, ref_napi.Type_>,
		argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>,
		fn:(args:haxe.extern.Rest<Dynamic>) -> Dynamic):global.Buffer {})
	function new(retType:ts.AnyOf2<String, ref_napi.Type_>,
		argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>, abi:Float,
		fn:(args:haxe.extern.Rest<Dynamic>) -> Dynamic);
	@:overload(function(retType:ts.AnyOf2<String, ref_napi.Type_>,
		argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>,
		fn:(args:haxe.extern.Rest<Dynamic>) -> Dynamic):global.Buffer {})
	@:selfCall
	function call(retType:ts.AnyOf2<String, ref_napi.Type_>,
		argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>, abi:Float,
		fn:(args:haxe.extern.Rest<Dynamic>) -> Dynamic):global.Buffer;
	@:overload(function(retType:ts.AnyOf2<String, ref_napi.Type_>,
		argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>,
		fn:(args:haxe.extern.Rest<Dynamic>) -> Dynamic):global.Buffer {})
	@:selfCall
	static function call_(retType:ts.AnyOf2<String, ref_napi.Type_>,
		argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>, abi:Float,
		fn:(args:haxe.extern.Rest<Dynamic>) -> Dynamic):global.Buffer;
}
