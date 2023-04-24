package node;

/**
	The `inspector` module provides an API for interacting with the V8 inspector.
	
	It can be accessed using:
	
	```js
	const inspector = require('inspector');
	```
**/
@:jsRequire("inspector") @valueModuleOnly extern class Inspector {
	/**
		Activate inspector on host and port. Equivalent to `node --inspect=[[host:]port]`, but can be done programmatically after node has
		started.
		
		If wait is `true`, will block until a client has connected to the inspect port
		and flow control has been passed to the debugger client.
		
		See the `security warning` regarding the `host`parameter usage.
	**/
	static function open(?port:Float, ?host:String, ?wait:Bool):Void;
	/**
		Deactivate the inspector. Blocks until there are no active connections.
	**/
	static function close():Void;
	/**
		Return the URL of the active inspector, or `undefined` if there is none.
		
		```console
		$ node --inspect -p 'inspector.url()'
		Debugger listening on ws://127.0.0.1:9229/166e272e-7a30-4d09-97ce-f1c012b43c34
		For help see https://nodejs.org/en/docs/inspector
		ws://127.0.0.1:9229/166e272e-7a30-4d09-97ce-f1c012b43c34
		
		$ node --inspect=localhost:3000 -p 'inspector.url()'
		Debugger listening on ws://localhost:3000/51cf8d0e-3c36-4c59-8efd-54519839e56a
		For help see https://nodejs.org/en/docs/inspector
		ws://localhost:3000/51cf8d0e-3c36-4c59-8efd-54519839e56a
		
		$ node -p 'inspector.url()'
		undefined
		```
	**/
	static function url():Null<String>;
	/**
		Blocks until a client (existing or connected later) has sent`Runtime.runIfWaitingForDebugger` command.
		
		An exception will be thrown if there is no active inspector.
	**/
	static function waitForDebugger():Void;
}