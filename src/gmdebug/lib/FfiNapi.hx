@:jsRequire("ffi-napi") @valueModuleOnly extern class FfiNapi {
	/**
		Get value of errno.
	**/
	static function errno():Float;

	static function CIF(retType:ts.AnyOf2<String, ref_napi.Type_>,
		types:Array<ts.AnyOf2<String, ref_napi.Type_>>, ?abi:Float):global.Buffer;
	static function CIF_var(retType:ts.AnyOf2<String, ref_napi.Type_>,
		types:Array<ts.AnyOf2<String, ref_napi.Type_>>, numFixedArgs:Float, ?abi:Float):global.Buffer;
	static final ffiType:{
		/**
			Get a `ffi_type *` Buffer appropriate for the given type.
		**/
		@:selfCall
		function call(type:ts.AnyOf2<String, ref_napi.Type_>):global.Buffer;
		var FFI_TYPE:ref_struct_di.StructType;
	};
	static final HAS_OBJC:Bool;
	static final FFI_TYPES:{};
	static final FFI_OK:Float;
	static final FFI_BAD_TYPEDEF:Float;
	static final FFI_BAD_ABI:Float;
	static final FFI_DEFAULT_ABI:Float;
	static final FFI_FIRST_ABI:Float;
	static final FFI_LAST_ABI:Float;
	static final FFI_SYSV:Float;
	static final FFI_UNIX64:Float;
	static final RTLD_LAZY:Float;
	static final RTLD_NOW:Float;
	static final RTLD_LOCAL:Float;
	static final RTLD_GLOBAL:Float;
	static final RTLD_NOLOAD:Float;
	static final RTLD_NODELETE:Float;
	static final RTLD_NEXT:global.Buffer;
	static final RTLD_DEFAULT:global.Buffer;
	static final LIB_EXT:String;

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
}
