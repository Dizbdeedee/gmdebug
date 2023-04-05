package node.fs;

/**
	Test whether or not the given path exists by checking with the file system.
	Then call the `callback` argument with either true or false:
	
	```js
	import { exists } from 'fs';
	
	exists('/etc/passwd', (e) => {
	   console.log(e ? 'it exists' : 'no passwd!');
	});
	```
	
	**The parameters for this callback are not consistent with other Node.js**
	**callbacks.** Normally, the first parameter to a Node.js callback is an `err`parameter, optionally followed by other parameters. The `fs.exists()` callback
	has only one boolean parameter. This is one reason `fs.access()` is recommended
	instead of `fs.exists()`.
	
	Using `fs.exists()` to check for the existence of a file before calling`fs.open()`, `fs.readFile()` or `fs.writeFile()` is not recommended. Doing
	so introduces a race condition, since other processes may change the file's
	state between the two calls. Instead, user code should open/read/write the
	file directly and handle the error raised if the file does not exist.
	
	**write (NOT RECOMMENDED)**
	
	```js
	import { exists, open, close } from 'fs';
	
	exists('myfile', (e) => {
	   if (e) {
	     console.error('myfile already exists');
	   } else {
	     open('myfile', 'wx', (err, fd) => {
	       if (err) throw err;
	
	       try {
	         writeMyData(fd);
	       } finally {
	         close(fd, (err) => {
	           if (err) throw err;
	         });
	       }
	     });
	   }
	});
	```
	
	**write (RECOMMENDED)**
	
	```js
	import { open, close } from 'fs';
	open('myfile', 'wx', (err, fd) => {
	   if (err) {
	     if (err.code === 'EEXIST') {
	       console.error('myfile already exists');
	       return;
	     }
	
	     throw err;
	   }
	
	   try {
	     writeMyData(fd);
	   } finally {
	     close(fd, (err) => {
	       if (err) throw err;
	     });
	   }
	});
	```
	
	**read (NOT RECOMMENDED)**
	
	```js
	import { open, close, exists } from 'fs';
	
	exists('myfile', (e) => {
	   if (e) {
	     open('myfile', 'r', (err, fd) => {
	       if (err) throw err;
	
	       try {
	         readMyData(fd);
	       } finally {
	         close(fd, (err) => {
	           if (err) throw err;
	         });
	       }
	     });
	   } else {
	     console.error('myfile does not exist');
	   }
	});
	```
	
	**read (RECOMMENDED)**
	
	```js
	import { open, close } from 'fs';
	
	open('myfile', 'r', (err, fd) => {
	   if (err) {
	     if (err.code === 'ENOENT') {
	       console.error('myfile does not exist');
	       return;
	     }
	
	     throw err;
	   }
	
	   try {
	     readMyData(fd);
	   } finally {
	     close(fd, (err) => {
	       if (err) throw err;
	     });
	   }
	});
	```
	
	The "not recommended" examples above check for existence and then use the
	file; the "recommended" examples are better because they use the file directly
	and handle the error, if any.
	
	In general, check for the existence of a file only if the file won’t be
	used directly, for example when its existence is a signal from another
	process.
**/
@:jsRequire("fs", "exists") @valueModuleOnly extern class Exists {
	/**
		Test whether or not the given path exists by checking with the file system.
		Then call the `callback` argument with either true or false:
		
		```js
		import { exists } from 'fs';
		
		exists('/etc/passwd', (e) => {
		   console.log(e ? 'it exists' : 'no passwd!');
		});
		```
		
		**The parameters for this callback are not consistent with other Node.js**
		**callbacks.** Normally, the first parameter to a Node.js callback is an `err`parameter, optionally followed by other parameters. The `fs.exists()` callback
		has only one boolean parameter. This is one reason `fs.access()` is recommended
		instead of `fs.exists()`.
		
		Using `fs.exists()` to check for the existence of a file before calling`fs.open()`, `fs.readFile()` or `fs.writeFile()` is not recommended. Doing
		so introduces a race condition, since other processes may change the file's
		state between the two calls. Instead, user code should open/read/write the
		file directly and handle the error raised if the file does not exist.
		
		**write (NOT RECOMMENDED)**
		
		```js
		import { exists, open, close } from 'fs';
		
		exists('myfile', (e) => {
		   if (e) {
		     console.error('myfile already exists');
		   } else {
		     open('myfile', 'wx', (err, fd) => {
		       if (err) throw err;
		
		       try {
		         writeMyData(fd);
		       } finally {
		         close(fd, (err) => {
		           if (err) throw err;
		         });
		       }
		     });
		   }
		});
		```
		
		**write (RECOMMENDED)**
		
		```js
		import { open, close } from 'fs';
		open('myfile', 'wx', (err, fd) => {
		   if (err) {
		     if (err.code === 'EEXIST') {
		       console.error('myfile already exists');
		       return;
		     }
		
		     throw err;
		   }
		
		   try {
		     writeMyData(fd);
		   } finally {
		     close(fd, (err) => {
		       if (err) throw err;
		     });
		   }
		});
		```
		
		**read (NOT RECOMMENDED)**
		
		```js
		import { open, close, exists } from 'fs';
		
		exists('myfile', (e) => {
		   if (e) {
		     open('myfile', 'r', (err, fd) => {
		       if (err) throw err;
		
		       try {
		         readMyData(fd);
		       } finally {
		         close(fd, (err) => {
		           if (err) throw err;
		         });
		       }
		     });
		   } else {
		     console.error('myfile does not exist');
		   }
		});
		```
		
		**read (RECOMMENDED)**
		
		```js
		import { open, close } from 'fs';
		
		open('myfile', 'r', (err, fd) => {
		   if (err) {
		     if (err.code === 'ENOENT') {
		       console.error('myfile does not exist');
		       return;
		     }
		
		     throw err;
		   }
		
		   try {
		     readMyData(fd);
		   } finally {
		     close(fd, (err) => {
		       if (err) throw err;
		     });
		   }
		});
		```
		
		The "not recommended" examples above check for existence and then use the
		file; the "recommended" examples are better because they use the file directly
		and handle the error, if any.
		
		In general, check for the existence of a file only if the file won’t be
		used directly, for example when its existence is a signal from another
		process.
	**/
	@:selfCall
	static function call(path:PathLike, callback:(exists:Bool) -> Void):Void;
}