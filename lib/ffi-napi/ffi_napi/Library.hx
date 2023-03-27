package ffi_napi;

/**
	Provides a friendly API on-top of `DynamicLibrary` and `ForeignFunction`.
**/
@:jsRequire("ffi-napi", "Library") extern class Library {
	function new(libFile:Null<String>, ?funcs:{ }, ?lib:Dynamic);
	@:selfCall
	function call(libFile:Null<String>, ?funcs:{ }, ?lib:Dynamic):Dynamic;
	/**
		The extension to use on libraries.
	**/
	var EXT : String;
	@:selfCall
	static function call_(libFile:Null<String>, ?funcs:{ }, ?lib:Dynamic):Dynamic;
	/**
		The extension to use on libraries.
	**/
	@:native("EXT")
	static var EXT_ : String;
}