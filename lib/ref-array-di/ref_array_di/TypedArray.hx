package ref_array_di;

extern class TypedArray<T> implements ArrayAccess<T> {
	var length : Float;
	function toArray():Array<T>;
	function toJSON():Array<T>;
	function inspect():String;
	var buffer : global.Buffer;
	function ref():global.Buffer;
}