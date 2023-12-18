package ffi_napi;

@:jsRequire("ffi-napi", "FFI_TYPE") extern class FFI_TYPE {
	/**
		Pass it an existing Buffer instance to use that as the backing buffer.
	**/
	@:overload(function(?data:{}):{} {})
	function new(arg:global.Buffer, ?data:{});

	/**
		Pass it an existing Buffer instance to use that as the backing buffer.
	**/
	@:overload(function(?data:{}):{} {})
	@:selfCall
	static function call(arg:global.Buffer, ?data:{}):{};

	static var fields:{};

	/**
		Adds a new field to the struct instance with the given name and type.
		Note that this function will throw an Error if any instances of the struct
		type have already been created, therefore this function must be called at the
		beginning, before any instances are created.
	**/
	static function defineProperty(name:String, type:ts.AnyOf2<String, ref_napi.Type_>):Void;

	/**
		Custom for struct type instances.
	**/
	static function toString():String;

	/**
		The size in bytes required to hold this datatype.
	**/
	static var size:Float;

	/**
		The current level of indirection of the buffer.
	**/
	static var indirection:Float;

	/**
		To invoke when `ref.get` is invoked on a buffer of this type.
	**/
	static function get(buffer:global.Buffer, offset:Float):Dynamic;

	/**
		To invoke when `ref.set` is invoked on a buffer of this type.
	**/
	static function set(buffer:global.Buffer, offset:Float, value:Dynamic):Void;

	/**
		The name to use during debugging for this datatype.
	**/
	@:optional
	static var name:String;

	/**
		The alignment of this datatype when placed inside a struct.
	**/
	@:optional
	static var alignment:Float;
}
