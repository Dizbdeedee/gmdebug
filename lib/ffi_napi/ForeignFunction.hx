package ffi_napi;

/**
	Represents a foreign function in another library. Manages all of the aspects
	of function execution, including marshalling the data parameters for the
	function into native types and also unmarshalling the return from function
	execution.
**/
@:jsRequire("ffi-napi", "ForeignFunction") extern class ForeignFunction {
	function new(ptr:global.Buffer, retType:ts.AnyOf2<String, ref_napi.Type_>, argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>, ?abi:Float);
	@:selfCall
	function call(args:haxe.extern.Rest<Dynamic>):Dynamic;
	function async(args:haxe.extern.Rest<Dynamic>):Void;
	@:selfCall
	static function call_(ptr:global.Buffer, retType:ts.AnyOf2<String, ref_napi.Type_>, argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>, ?abi:Float):ForeignFunction;
}