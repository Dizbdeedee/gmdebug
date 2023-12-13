package ffi_napi;

/**
	This class loads and fetches function pointers for dynamic libraries
	(.so, .dylib, etc). After the libray's function pointer is acquired, then you
	call `get(symbol)` to retreive a pointer to an exported symbol. You need to
	call `get___` on the pointer to dereference it into its actual value, or
	turn the pointer into a callable function with `ForeignFunction`.
**/
@:jsRequire("ffi-napi", "DynamicLibrary") extern class DynamicLibrary {
	function new(?path:String, ?mode:Float);

	/**
		Close library, returns the result of the `dlclose` system function.
	**/
	function close():Float;

	/**
		Get a symbol from this library.
	**/
	function get(symbol:String):global.Buffer;

	/**
		Get the result of the `dlerror` system function.
	**/
	function error():String;

	@:selfCall
	static function call(?path:String, ?mode:Float):DynamicLibrary;
	static var FLAGS:{
		var RTLD_LAZY:Float;
		var RTLD_NOW:Float;
		var RTLD_LOCAL:Float;
		var RTLD_GLOBAL:Float;
		var RTLD_NOLOAD:Float;
		var RTLD_NODELETE:Float;
		var RTLD_NEXT:global.Buffer;
		var RTLD_DEFAUL:global.Buffer;
	};
}
