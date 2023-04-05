package ref_array_di;

typedef FixedLengthArrayType<T> = {
	@:overload(function(data:Array<Float>, ?length:Float):TypedArray<T> { })
	@:overload(function(data:global.Buffer, ?length:Float):TypedArray<T> { })
	@:selfCall
	function call(?length:Float):TypedArray<T>;
	var fixedLength : Float;
	var BYTES_PER_ELEMENT : Float;
	/**
		The reference to the base type.
	**/
	var type : ref_napi.Type_;
	/**
		Accepts a Buffer instance that should be an already-populated with data
		for the ArrayType. The "length" of the Array is determined by searching
		through the buffer's contents until an aligned NULL pointer is encountered.
	**/
	function untilZeros(buffer:global.Buffer):TypedArray<T>;
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