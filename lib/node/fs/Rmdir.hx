package node.fs;

/**
	Asynchronous [`rmdir(2)`](http://man7.org/linux/man-pages/man2/rmdir.2.html). No arguments other than a possible exception are given
	to the completion callback.
	
	Using `fs.rmdir()` on a file (not a directory) results in an `ENOENT` error on
	Windows and an `ENOTDIR` error on POSIX.
	
	To get a behavior similar to the `rm -rf` Unix command, use {@link rm} with options `{ recursive: true, force: true }`.
**/
@:jsRequire("fs", "rmdir") @valueModuleOnly extern class Rmdir {
	/**
		Asynchronous [`rmdir(2)`](http://man7.org/linux/man-pages/man2/rmdir.2.html). No arguments other than a possible exception are given
		to the completion callback.
		
		Using `fs.rmdir()` on a file (not a directory) results in an `ENOENT` error on
		Windows and an `ENOTDIR` error on POSIX.
		
		To get a behavior similar to the `rm -rf` Unix command, use {@link rm} with options `{ recursive: true, force: true }`.
	**/
	@:overload(function(path:PathLike, options:RmDirOptions, callback:NoParamCallback):Void { })
	@:selfCall
	static function call(path:PathLike, callback:NoParamCallback):Void;
}