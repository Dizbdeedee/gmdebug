package ffi_napi;

/**
	Represents a foreign function in another library. Manages all of the aspects
	of function execution, including marshalling the data parameters for the
	function into native types and also unmarshalling the return from function
	execution.
**/
typedef IForeignFunction = {
	@:selfCall
	function call(args:haxe.extern.Rest<Dynamic>):Dynamic;
	function async(args:haxe.extern.Rest<Dynamic>):Void;
};
