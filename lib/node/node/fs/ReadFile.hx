package node.fs;

/**
	Asynchronously reads the entire contents of a file.
	
	```js
	import { readFile } from 'fs';
	
	readFile('/etc/passwd', (err, data) => {
	   if (err) throw err;
	   console.log(data);
	});
	```
	
	The callback is passed two arguments `(err, data)`, where `data` is the
	contents of the file.
	
	If no encoding is specified, then the raw buffer is returned.
	
	If `options` is a string, then it specifies the encoding:
	
	```js
	import { readFile } from 'fs';
	
	readFile('/etc/passwd', 'utf8', callback);
	```
	
	When the path is a directory, the behavior of `fs.readFile()` and {@link readFileSync} is platform-specific. On macOS, Linux, and Windows, an
	error will be returned. On FreeBSD, a representation of the directory's contents
	will be returned.
	
	```js
	import { readFile } from 'fs';
	
	// macOS, Linux, and Windows
	readFile('<directory>', (err, data) => {
	   // => [Error: EISDIR: illegal operation on a directory, read <directory>]
	});
	
	//  FreeBSD
	readFile('<directory>', (err, data) => {
	   // => null, <data>
	});
	```
	
	It is possible to abort an ongoing request using an `AbortSignal`. If a
	request is aborted the callback is called with an `AbortError`:
	
	```js
	import { readFile } from 'fs';
	
	const controller = new AbortController();
	const signal = controller.signal;
	readFile(fileInfo[0].name, { signal }, (err, buf) => {
	   // ...
	});
	// When you want to abort the request
	controller.abort();
	```
	
	The `fs.readFile()` function buffers the entire file. To minimize memory costs,
	when possible prefer streaming via `fs.createReadStream()`.
	
	Aborting an ongoing request does not abort individual operating
	system requests but rather the internal buffering `fs.readFile` performs.
	
	Asynchronously reads the entire contents of a file.
	
	Asynchronously reads the entire contents of a file.
	
	Asynchronously reads the entire contents of a file.
**/
@:jsRequire("fs", "readFile") @valueModuleOnly extern class ReadFile {
	/**
		Asynchronously reads the entire contents of a file.
		
		```js
		import { readFile } from 'fs';
		
		readFile('/etc/passwd', (err, data) => {
		   if (err) throw err;
		   console.log(data);
		});
		```
		
		The callback is passed two arguments `(err, data)`, where `data` is the
		contents of the file.
		
		If no encoding is specified, then the raw buffer is returned.
		
		If `options` is a string, then it specifies the encoding:
		
		```js
		import { readFile } from 'fs';
		
		readFile('/etc/passwd', 'utf8', callback);
		```
		
		When the path is a directory, the behavior of `fs.readFile()` and {@link readFileSync} is platform-specific. On macOS, Linux, and Windows, an
		error will be returned. On FreeBSD, a representation of the directory's contents
		will be returned.
		
		```js
		import { readFile } from 'fs';
		
		// macOS, Linux, and Windows
		readFile('<directory>', (err, data) => {
		   // => [Error: EISDIR: illegal operation on a directory, read <directory>]
		});
		
		//  FreeBSD
		readFile('<directory>', (err, data) => {
		   // => null, <data>
		});
		```
		
		It is possible to abort an ongoing request using an `AbortSignal`. If a
		request is aborted the callback is called with an `AbortError`:
		
		```js
		import { readFile } from 'fs';
		
		const controller = new AbortController();
		const signal = controller.signal;
		readFile(fileInfo[0].name, { signal }, (err, buf) => {
		   // ...
		});
		// When you want to abort the request
		controller.abort();
		```
		
		The `fs.readFile()` function buffers the entire file. To minimize memory costs,
		when possible prefer streaming via `fs.createReadStream()`.
		
		Aborting an ongoing request does not abort individual operating
		system requests but rather the internal buffering `fs.readFile` performs.
	**/
	@:overload(function(path:PathOrFileDescriptor, options:ts.AnyOf2<String, { var encoding : global.BufferEncoding; @:optional var flag : String; } & node.events.eventemitter.Abortable>, callback:(err:Null<global.nodejs.ErrnoException>, data:String) -> Void):Void { })
	@:overload(function(path:PathOrFileDescriptor, options:Null<ts.AnyOf2<String, ObjectEncodingOptions & { @:optional var flag : String; } & node.events.eventemitter.Abortable>>, callback:(err:Null<global.nodejs.ErrnoException>, data:ts.AnyOf2<String, node.buffer.Buffer>) -> Void):Void { })
	@:overload(function(path:PathOrFileDescriptor, callback:(err:Null<global.nodejs.ErrnoException>, data:node.buffer.Buffer) -> Void):Void { })
	@:selfCall
	static function call(path:PathOrFileDescriptor, options:Null<{ @:optional var encoding : Any; @:optional var flag : String; } & node.events.eventemitter.Abortable>, callback:(err:Null<global.nodejs.ErrnoException>, data:node.buffer.Buffer) -> Void):Void;
}