@:jsRequire("ref-napi") @valueModuleOnly extern class RefNapi {
	/**
		Get the memory address of buffer.
	**/
	static function address(buffer:global.Buffer):Float;

	/**
		Get the memory address of buffer.
	**/
	static function hexAddress(buffer:global.Buffer):String;

	/**
		Allocate the memory with the given value written to it.
	**/
	static function alloc(type:ts.AnyOf2<String, ref_napi.Type_>, ?value:Dynamic):global.Buffer;

	/**
		Allocate the memory with the given string written to it with the given
		encoding (defaults to utf8). The buffer is 1 byte longer than the
		string itself, and is NULL terminated.
	**/
	static function allocCString(string:String, ?encoding:String):global.Buffer;

	/**
		Coerce a type. String are looked up from the ref.types object.
	**/
	static function coerceType(type:ts.AnyOf2<String, ref_napi.Type_>):ref_napi.Type_;

	/**
		Get value after dereferencing buffer.
		That is, first it checks the indirection count of buffer's type, and
		if it's greater than 1 then it merely returns another Buffer, but with
		one level less indirection.
	**/
	static function deref(buffer:global.Buffer):Dynamic;

	/**
		Create clone of the type, with decremented indirection level by 1.
	**/
	static function derefType(type:ts.AnyOf2<String, ref_napi.Type_>):ref_napi.Type_;

	/**
		Check the indirection level and return a dereferenced when necessary.
	**/
	static function get(buffer:global.Buffer, ?offset:Float, ?type:ts.AnyOf2<String, ref_napi.Type_>):Dynamic;

	/**
		Get type of the buffer. Create a default type when none exists.
	**/
	static function getType(buffer:global.Buffer):ref_napi.Type_;

	/**
		Check the NULL.
	**/
	static function isNull(buffer:global.Buffer):Bool;

	/**
		Read C string until the first NULL.
	**/
	static function readCString(buffer:global.Buffer, ?offset:Float):String;

	/**
		Read a big-endian signed 64-bit int.
		If there is losing precision, then return a string, otherwise a number.
	**/
	static function readInt64BE(buffer:global.Buffer, ?offset:Float):ts.AnyOf2<String, Float>;

	/**
		Read a little-endian signed 64-bit int.
		If there is losing precision, then return a string, otherwise a number.
	**/
	static function readInt64LE(buffer:global.Buffer, ?offset:Float):ts.AnyOf2<String, Float>;

	/**
		Read a JS Object that has previously been written.
	**/
	static function readObject(buffer:global.Buffer, ?offset:Float):Dynamic;

	/**
		Read data from the pointer.
	**/
	static function readPointer(buffer:global.Buffer, ?offset:Float, ?length:Float):global.Buffer;

	/**
		Read a big-endian unsigned 64-bit int.
		If there is losing precision, then return a string, otherwise a number.
	**/
	static function readUInt64BE(buffer:global.Buffer, ?offset:Float):ts.AnyOf2<String, Float>;

	/**
		Read a little-endian unsigned 64-bit int.
		If there is losing precision, then return a string, otherwise a number.
	**/
	static function readUInt64LE(buffer:global.Buffer, ?offset:Float):ts.AnyOf2<String, Float>;

	/**
		Create pointer to buffer.
	**/
	static function ref(buffer:global.Buffer):global.Buffer;

	/**
		Create clone of the type, with incremented indirection level by 1.
	**/
	static function refType(type:ts.AnyOf2<String, ref_napi.Type_>):ref_napi.Type_;

	/**
		Create buffer with the specified size, with the same address as source.
		This function "attaches" source to the returned buffer to prevent it from
		being garbage collected.
	**/
	static function reinterpret(buffer:global.Buffer, size:Float, ?offset:Float):global.Buffer;

	/**
		Scan past the boundary of the buffer's length until it finds size number
		of aligned NULL bytes.
	**/
	static function reinterpretUntilZeros(buffer:global.Buffer, size:Float, ?offset:Float):global.Buffer;

	/**
		Write pointer if the indirection is 1, otherwise write value.
	**/
	static function set(buffer:global.Buffer, offset:Float, value:Dynamic,
		?type:ts.AnyOf2<String, ref_napi.Type_>):Void;

	/**
		Write the string as a NULL terminated. Default encoding is utf8.
	**/
	static function writeCString(buffer:global.Buffer, offset:Float, string:String, ?encoding:String):Void;

	/**
		Write a big-endian signed 64-bit int.
	**/
	static function writeInt64BE(buffer:global.Buffer, offset:Float, input:ts.AnyOf2<String, Float>):Void;

	/**
		Write a little-endian signed 64-bit int.
	**/
	static function writeInt64LE(buffer:global.Buffer, offset:Float, input:ts.AnyOf2<String, Float>):Void;

	/**
		Write the JS Object. This function "attaches" object to buffer to prevent
		it from being garbage collected.
	**/
	static function writeObject(buffer:global.Buffer, offset:Float, object:Dynamic):Void;

	/**
		Write the memory address of pointer to buffer at the specified offset. This
		function "attaches" object to buffer to prevent it from being garbage collected.
	**/
	static function writePointer(buffer:global.Buffer, offset:Float, pointer:global.Buffer):Void;

	/**
		Write a big-endian unsigned 64-bit int.
	**/
	static function writeUInt64BE(buffer:global.Buffer, offset:Float, input:ts.AnyOf2<String, Float>):Void;

	/**
		Write a little-endian unsigned 64-bit int.
	**/
	static function writeUInt64LE(buffer:global.Buffer, offset:Float, input:ts.AnyOf2<String, Float>):Void;

	/**
		Attach object to buffer such.
		It prevents object from being garbage collected until buffer does.
	**/
	static function _attach(buffer:global.Buffer, object:Dynamic):Void;

	/**
		Same as ref.reinterpret, except that this version does not attach buffer.
	**/
	static function _reinterpret(buffer:global.Buffer, size:Float, ?offset:Float):global.Buffer;

	/**
		Same as ref.reinterpretUntilZeros, except that this version does not attach buffer.
	**/
	static function _reinterpretUntilZeros(buffer:global.Buffer, size:Float, ?offset:Float):global.Buffer;

	/**
		Same as ref.writePointer, except that this version does not attach pointer.
	**/
	static function _writePointer(buffer:global.Buffer, offset:Float, pointer:global.Buffer):Void;

	/**
		Same as ref.writeObject, except that this version does not attach object.
	**/
	static function _writeObject(buffer:global.Buffer, offset:Float, object:Dynamic):Void;

	/**
		A Buffer that references the C NULL pointer.
	**/
	static var NULL:global.Buffer;

	/**
		A pointer-sized buffer pointing to NULL.
	**/
	static var NULL_POINTER:global.Buffer;

	/**
		Represents the native endianness of the processor ("LE" or "BE").
	**/
	static var endianness:String;

	/**
		Default types.
	**/
	static var types:{
		var void:ref_napi.Type_;
		var int64:ref_napi.Type_;
		var ushort:ref_napi.Type_;
		var int:ref_napi.Type_;
		var uint64:ref_napi.Type_;
		var float:ref_napi.Type_;
		var uint:ref_napi.Type_;
		var long:ref_napi.Type_;
		var double:ref_napi.Type_;
		var int8:ref_napi.Type_;
		var ulong:ref_napi.Type_;
		var Object:ref_napi.Type_;
		var uint8:ref_napi.Type_;
		var longlong:ref_napi.Type_;
		var CString:ref_napi.Type_;
		var int16:ref_napi.Type_;
		var ulonglong:ref_napi.Type_;
		var bool:ref_napi.Type_;
		var uint16:ref_napi.Type_;
		var char:ref_napi.Type_;
		var byte:ref_napi.Type_;
		var int32:ref_napi.Type_;
		var uchar:ref_napi.Type_;
		var size_t:ref_napi.Type_;
		var uint32:ref_napi.Type_;
		var short:ref_napi.Type_;
	};

	static var alignof:{
		var pointer:Float;
		var int64:Float;
		var ushort:Float;
		var int:Float;
		var uint64:Float;
		var float:Float;
		var uint:Float;
		var long:Float;
		var double:Float;
		var int8:Float;
		var ulong:Float;
		var Object:Float;
		var uint8:Float;
		var longlong:Float;
		var int16:Float;
		var ulonglong:Float;
		var bool:Float;
		var uint16:Float;
		var char:Float;
		var byte:Float;
		var int32:Float;
		var uchar:Float;
		var size_t:Float;
		var uint32:Float;
		var short:Float;
	};
	static var sizeof:{
		var pointer:Float;
		var int64:Float;
		var ushort:Float;
		var int:Float;
		var uint64:Float;
		var float:Float;
		var uint:Float;
		var long:Float;
		var double:Float;
		var int8:Float;
		var ulong:Float;
		var Object:Float;
		var uint8:Float;
		var longlong:Float;
		var int16:Float;
		var ulonglong:Float;
		var bool:Float;
		var uint16:Float;
		var char:Float;
		var byte:Float;
		var int32:Float;
		var uchar:Float;
		var size_t:Float;
		var uint32:Float;
		var short:Float;
	};
}
