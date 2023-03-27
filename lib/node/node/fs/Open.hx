package node.fs;

/**
	Asynchronous file open. See the POSIX [`open(2)`](http://man7.org/linux/man-pages/man2/open.2.html) documentation for more details.
	
	`mode` sets the file mode (permission and sticky bits), but only if the file was
	created. On Windows, only the write permission can be manipulated; see {@link chmod}.
	
	The callback gets two arguments `(err, fd)`.
	
	Some characters (`< > : " / \ | ? *`) are reserved under Windows as documented
	by [Naming Files, Paths, and Namespaces](https://docs.microsoft.com/en-us/windows/desktop/FileIO/naming-a-file). Under NTFS, if the filename contains
	a colon, Node.js will open a file system stream, as described by[this MSDN page](https://docs.microsoft.com/en-us/windows/desktop/FileIO/using-streams).
	
	Functions based on `fs.open()` exhibit this behavior as well:`fs.writeFile()`, `fs.readFile()`, etc.
	
	Asynchronous open(2) - open and possibly create a file. If the file is created, its mode will be `0o666`.
**/
@:jsRequire("fs", "open") @valueModuleOnly extern class Open {
	/**
		Asynchronous file open. See the POSIX [`open(2)`](http://man7.org/linux/man-pages/man2/open.2.html) documentation for more details.
		
		`mode` sets the file mode (permission and sticky bits), but only if the file was
		created. On Windows, only the write permission can be manipulated; see {@link chmod}.
		
		The callback gets two arguments `(err, fd)`.
		
		Some characters (`< > : " / \ | ? *`) are reserved under Windows as documented
		by [Naming Files, Paths, and Namespaces](https://docs.microsoft.com/en-us/windows/desktop/FileIO/naming-a-file). Under NTFS, if the filename contains
		a colon, Node.js will open a file system stream, as described by[this MSDN page](https://docs.microsoft.com/en-us/windows/desktop/FileIO/using-streams).
		
		Functions based on `fs.open()` exhibit this behavior as well:`fs.writeFile()`, `fs.readFile()`, etc.
	**/
	@:overload(function(path:PathLike, flags:ts.AnyOf2<String, Float>, callback:(err:Null<global.nodejs.ErrnoException>, fd:Float) -> Void):Void { })
	@:selfCall
	static function call(path:PathLike, flags:ts.AnyOf2<String, Float>, mode:Null<ts.AnyOf2<String, Float>>, callback:(err:Null<global.nodejs.ErrnoException>, fd:Float) -> Void):Void;
}