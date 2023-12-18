package ref_array_di;

extern class TypedArray<T> implements ArrayAccess<T> {
	var length:Float;
	function toArray():Array<T>;
	function toJSON():Array<T>;
	function inspect():String;
	var buffer:ref_napi.buffer.Buffer;
	function ref():ref_napi.buffer.Buffer;
}
