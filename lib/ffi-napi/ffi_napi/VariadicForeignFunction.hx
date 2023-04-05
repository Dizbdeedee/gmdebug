package ffi_napi;

/**
	For when you want to call to a C function with variable amount of arguments.
	i.e. `printf`.
	
	This function takes care of caching and reusing `ForeignFunction` instances that
	contain the same ffi_type argument signature.
**/
@:jsRequire("ffi-napi", "VariadicForeignFunction") extern class VariadicForeignFunction {
	function new(ptr:global.Buffer, ret:ts.AnyOf2<String, ref_napi.Type_>, fixedArgs:Array<ts.AnyOf2<String, ref_napi.Type_>>, ?abi:Float);
	/**
		What gets returned is another function that needs to be invoked with the rest
		of the variadic types that are being invoked from the function.
	**/
	@:selfCall
	function call(args:haxe.extern.Rest<ts.AnyOf2<String, ref_napi.Type_>>):ForeignFunction;
	/**
		Return type as a property of the function generator to
		allow for monkey patching the return value in the very rare case where the
		return type is variadic as well
	**/
	var returnType : ref_napi.Type_;
	@:selfCall
	static function call_(ptr:global.Buffer, ret:ts.AnyOf2<String, ref_napi.Type_>, fixedArgs:Array<ts.AnyOf2<String, ref_napi.Type_>>, ?abi:Float):VariadicForeignFunction;
}