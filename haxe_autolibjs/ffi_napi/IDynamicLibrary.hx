package ffi_napi;

/**
	This class loads and fetches function pointers for dynamic libraries
	(.so, .dylib, etc). After the libray's function pointer is acquired, then you
	call `get(symbol)` to retreive a pointer to an exported symbol. You need to
	call `get___` on the pointer to dereference it into its actual value, or
	turn the pointer into a callable function with `ForeignFunction`.
**/
typedef IDynamicLibrary = {
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
};
