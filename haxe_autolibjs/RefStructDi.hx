@:jsRequire("ref-struct-di") extern class RefStructDi {
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
		}; /** A Buffer that references the C NULL pointer. **/ var NULL:global.Buffer;
	}):{
		@:overload(function(?fields:Array<ts.Tuple2<String, ts.AnyOf2<String, ref_napi.Type_>>>,
			?opt:{@:optional var packed:Bool;}):ref_struct_di.StructType {})
		@:selfCall
		function call(?fields:{}, ?opt:{@:optional var packed:Bool;}):ref_struct_di.StructType;
	};
}
