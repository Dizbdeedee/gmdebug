package node.zlib;

@:jsRequire("zlib", "unzip") @valueModuleOnly extern class Unzip_ {
	@:overload(function(buf:InputType, options:ZlibOptions, callback:CompressCallback):Void { })
	@:selfCall
	static function call(buf:InputType, callback:CompressCallback):Void;
}