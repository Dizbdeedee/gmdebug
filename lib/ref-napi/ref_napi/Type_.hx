package ref_napi;

typedef Type_ = {
	/**
		The size in bytes required to hold this datatype.
	**/
	var size : Float;
	/**
		The current level of indirection of the buffer.
	**/
	var indirection : Float;
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
	var name : String;
	/**
		The alignment of this datatype when placed inside a struct.
	**/
	@:optional
	var alignment : Float;
};