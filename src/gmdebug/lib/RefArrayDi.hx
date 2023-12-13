@:jsRequire("ref-array-di") extern class RefArrayDi {
	@:selfCall
	static function call(ref:{
		/** Coerce a type. String are looked up from the ref.types object. **/ dynamic function coerceType(type:ts.AnyOf2<String,
			ref_napi.Type_>):ref_napi.Type_; /** Check the indirection level and return a dereferenced when necessary. **/ dynamic function get(buffer:global.Buffer,
			?offset:Float,
			?type:ts.AnyOf2<String,
				ref_napi.Type_>):Dynamic; /** Write pointer if the indirection is 1, otherwise write value. **/ dynamic function set(buffer:global.Buffer,
			offset:Float, value:Dynamic,
			?type:ts.AnyOf2<String, ref_napi.Type_>):Void;
		var alignof:{
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
		var sizeof:{
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
		}; /** Read data from the pointer. **/ dynamic function readPointer(buffer:global.Buffer,
			?offset:Float,
			?length:Float):global.Buffer; /** Write the memory address of pointer to buffer at the specified offset. Thisfunction "attaches" object to buffer to prevent it from being garbage collected. **/ dynamic function writePointer(buffer:global.Buffer,
			offset:Float,
			pointer:global.Buffer):Void; /** Create buffer with the specified size, with the same address as source.This function "attaches" source to the returned buffer to prevent it frombeing garbage collected. **/ dynamic function reinterpret(buffer:global.Buffer,
			size:Float,
			?offset:Float):global.Buffer; /** Scan past the boundary of the buffer's length until it finds size numberof aligned NULL bytes. **/ dynamic function reinterpretUntilZeros(buffer:global.Buffer,
			size:Float,
			?offset:Float):global.Buffer; /** Create pointer to buffer. **/ dynamic function ref(buffer:global.Buffer):global.Buffer; /** Default types. **/ var types:{
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
		}; /** A Buffer that references the C NULL pointer. **/ var NULL:global.Buffer;
	}):{
		@:overload(function<T>(type:ts.AnyOf2<String, ref_napi.Type_>,
			?length:Float):ref_array_di.ArrayType<T> {})
		@:selfCall
		function call<T>(type:ts.AnyOf2<String, ref_napi.Type_>,
			length:Float):ref_array_di.FixedLengthArrayType<T>;
	};
}
