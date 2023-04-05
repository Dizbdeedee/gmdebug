package node.fs;

/**
	Changes the access and modification times of a file in the same way as {@link utimes}, with the difference that if the path refers to a symbolic
	link, then the link is not dereferenced: instead, the timestamps of the
	symbolic link itself are changed.
	
	No arguments other than a possible exception are given to the completion
	callback.
**/
@:jsRequire("fs", "lutimes") @valueModuleOnly extern class Lutimes {
	/**
		Changes the access and modification times of a file in the same way as {@link utimes}, with the difference that if the path refers to a symbolic
		link, then the link is not dereferenced: instead, the timestamps of the
		symbolic link itself are changed.
		
		No arguments other than a possible exception are given to the completion
		callback.
	**/
	@:selfCall
	static function call(path:PathLike, atime:TimeLike, mtime:TimeLike, callback:NoParamCallback):Void;
}