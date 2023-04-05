package node;

/**
	> Stability: 2 - Stable
	
	The `net` module provides an asynchronous network API for creating stream-based
	TCP or `IPC` servers ({@link createServer}) and clients
	({@link createConnection}).
	
	It can be accessed using:
	
	```js
	const net = require('net');
	```
**/
@:jsRequire("net") @valueModuleOnly extern class Net {
	/**
		Creates a new TCP or `IPC` server.
		
		If `allowHalfOpen` is set to `true`, when the other end of the socket
		signals the end of transmission, the server will only send back the end of
		transmission when `socket.end()` is explicitly called. For example, in the
		context of TCP, when a FIN packed is received, a FIN packed is sent
		back only when `socket.end()` is explicitly called. Until then the
		connection is half-closed (non-readable but still writable). See `'end'` event and [RFC 1122](https://tools.ietf.org/html/rfc1122) (section 4.2.2.13) for more information.
		
		If `pauseOnConnect` is set to `true`, then the socket associated with each
		incoming connection will be paused, and no data will be read from its handle.
		This allows connections to be passed between processes without any data being
		read by the original process. To begin reading data from a paused socket, call `socket.resume()`.
		
		The server can be a TCP server or an `IPC` server, depending on what it `listen()` to.
		
		Here is an example of an TCP echo server which listens for connections
		on port 8124:
		
		```js
		const net = require('net');
		const server = net.createServer((c) => {
		   // 'connection' listener.
		   console.log('client connected');
		   c.on('end', () => {
		     console.log('client disconnected');
		   });
		   c.write('hello\r\n');
		   c.pipe(c);
		});
		server.on('error', (err) => {
		   throw err;
		});
		server.listen(8124, () => {
		   console.log('server bound');
		});
		```
		
		Test this by using `telnet`:
		
		```console
		$ telnet localhost 8124
		```
		
		To listen on the socket `/tmp/echo.sock`:
		
		```js
		server.listen('/tmp/echo.sock', () => {
		   console.log('server bound');
		});
		```
		
		Use `nc` to connect to a Unix domain socket server:
		
		```console
		$ nc -U /tmp/echo.sock
		```
	**/
	@:overload(function(?options:node.net.ServerOpts, ?connectionListener:(socket:node.net.Socket) -> Void):node.net.Server { })
	static function createServer(?connectionListener:(socket:node.net.Socket) -> Void):node.net.Server;
	/**
		Aliases to {@link createConnection}.
		
		Possible signatures:
		
		* {@link connect}
		* {@link connect} for `IPC` connections.
		* {@link connect} for TCP connections.
	**/
	@:overload(function(port:Float, ?host:String, ?connectionListener:() -> Void):node.net.Socket { })
	@:overload(function(path:String, ?connectionListener:() -> Void):node.net.Socket { })
	static function connect(options:node.net.NetConnectOpts, ?connectionListener:() -> Void):node.net.Socket;
	/**
		A factory function, which creates a new {@link Socket},
		immediately initiates connection with `socket.connect()`,
		then returns the `net.Socket` that starts the connection.
		
		When the connection is established, a `'connect'` event will be emitted
		on the returned socket. The last parameter `connectListener`, if supplied,
		will be added as a listener for the `'connect'` event **once**.
		
		Possible signatures:
		
		* {@link createConnection}
		* {@link createConnection} for `IPC` connections.
		* {@link createConnection} for TCP connections.
		
		The {@link connect} function is an alias to this function.
	**/
	@:overload(function(port:Float, ?host:String, ?connectionListener:() -> Void):node.net.Socket { })
	@:overload(function(path:String, ?connectionListener:() -> Void):node.net.Socket { })
	static function createConnection(options:node.net.NetConnectOpts, ?connectionListener:() -> Void):node.net.Socket;
	/**
		Tests if input is an IP address. Returns `0` for invalid strings,
		returns `4` for IP version 4 addresses, and returns `6` for IP version 6
		addresses.
	**/
	static function isIP(input:String):Float;
	/**
		Returns `true` if input is a version 4 IP address, otherwise returns `false`.
	**/
	static function isIPv4(input:String):Bool;
	/**
		Returns `true` if input is a version 6 IP address, otherwise returns `false`.
	**/
	static function isIPv6(input:String):Bool;
}