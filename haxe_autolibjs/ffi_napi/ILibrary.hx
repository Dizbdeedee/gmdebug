package ffi_napi;

/**
	Provides a friendly API on-top of `DynamicLibrary` and `ForeignFunction`.
**/
typedef ILibrary = {
	@:selfCall
	function call(libFile:Null<String>, ?funcs:{}, ?lib:Dynamic):Dynamic;

	/**
		The extension to use on libraries.
	**/
	var EXT:String;
};
