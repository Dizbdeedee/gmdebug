package node.fs;

/**
	Returns the resolved pathname.
	
	For detailed information, see the documentation of the asynchronous version of
	this API: {@link realpath}.
	
	Synchronous realpath(3) - return the canonicalized absolute pathname.
	
	Synchronous realpath(3) - return the canonicalized absolute pathname.
**/
@:jsRequire("fs", "realpathSync") @valueModuleOnly extern class RealpathSync {
	/**
		Returns the resolved pathname.
		
		For detailed information, see the documentation of the asynchronous version of
		this API: {@link realpath}.
	**/
	@:overload(function(path:PathLike, options:BufferEncodingOption):node.buffer.Buffer { })
	@:overload(function(path:PathLike, ?options:EncodingOption):ts.AnyOf2<String, node.buffer.Buffer> { })
	@:selfCall
	static function call(path:PathLike, ?options:EncodingOption):String;
	@:overload(function(path:PathLike, options:BufferEncodingOption):node.buffer.Buffer { })
	@:overload(function(path:PathLike, ?options:EncodingOption):ts.AnyOf2<String, node.buffer.Buffer> { })
	static function native(path:PathLike, ?options:EncodingOption):String;
}