package ffi_napi;

/**
	Creates and returns a type for a C function pointer.
**/
@:jsRequire("ffi-napi", "Function") extern class Function {
	function new(retType:ts.AnyOf2<String, ref_napi.Type_>,
		argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>, ?abi:Float);

	/**
		The type of return value.
	**/
	var retType:ref_napi.Type_;

	/**
		The type of arguments.
	**/
	var argTypes:Array<ref_napi.Type_>;

	/**
		Is set for node-ffi functions.
	**/
	var ffi_type:global.Buffer;

	var abi:Float;

	/**
		Get a `Callback` pointer of this function type.
	**/
	function toPointer(fn:(args:haxe.extern.Rest<Dynamic>) -> Dynamic):global.Buffer;

	/**
		Get a `ForeignFunction` of this function type.
	**/
	function toFunction(buf:global.Buffer):ForeignFunction;

	/**
		The size in bytes required to hold this datatype.
	**/
	var size:Float;

	/**
		The current level of indirection of the buffer.
	**/
	var indirection:Float;

	/**
		To invoke when `ref.get` is invoked on a buffer of this type.
	**/
	function get(buffer:global.Buffer, offset:Float):Dynamic;

	/**
		To invoke when `ref.set` is invoked on a buffer of this type.
	**/
	function set(buffer:global.Buffer, offset:Float, value:Dynamic):Void;

	/**
		The name to use during debugging for this datatype.
	**/
	@:optional
	var name:String;

	/**
		The alignment of this datatype when placed inside a struct.
	**/
	@:optional
	var alignment:Float;

	@:selfCall
	static function call(retType:ts.AnyOf2<String, ref_napi.Type_>,
		argTypes:Array<ts.AnyOf2<String, ref_napi.Type_>>, ?abi:Float):Function;
}
