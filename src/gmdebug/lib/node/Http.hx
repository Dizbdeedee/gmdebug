package node;

/**
	To use the HTTP server and client one must `require('http')`.
	
	The HTTP interfaces in Node.js are designed to support many features
	of the protocol which have been traditionally difficult to use.
	In particular, large, possibly chunk-encoded, messages. The interface is
	careful to never buffer entire requests or responses, so the
	user is able to stream data.
	
	HTTP message headers are represented by an object like this:
	
	```js
	{ 'content-length': '123',
	   'content-type': 'text/plain',
	   'connection': 'keep-alive',
	   'host': 'mysite.com',
	   'accept': '*' }
	```
	
	Keys are lowercased. Values are not modified.
	
	In order to support the full spectrum of possible HTTP applications, the Node.js
	HTTP API is very low-level. It deals with stream handling and message
	parsing only. It parses a message into headers and body but it does not
	parse the actual headers or the body.
	
	See `message.headers` for details on how duplicate headers are handled.
	
	The raw headers as they were received are retained in the `rawHeaders`property, which is an array of `[key, value, key2, value2, ...]`. For
	example, the previous message header object might have a `rawHeaders`list like the following:
	
	```js
	[ 'ConTent-Length', '123456',
	   'content-LENGTH', '123',
	   'content-type', 'text/plain',
	   'CONNECTION', 'keep-alive',
	   'Host', 'mysite.com',
	   'accepT', '*' ]
	```
**/
@:jsRequire("http") @valueModuleOnly extern class Http {
	/**
		Returns a new instance of {@link Server}.
		
		The `requestListener` is a function which is automatically
		added to the `'request'` event.
	**/
	@:overload(function(options:node.http.ServerOptions, ?requestListener:node.http.RequestListener):node.http.Server { })
	static function createServer(?requestListener:node.http.RequestListener):node.http.Server;
	/**
		Node.js maintains several connections per server to make HTTP requests.
		This function allows one to transparently issue requests.
		
		`url` can be a string or a `URL` object. If `url` is a
		string, it is automatically parsed with `new URL()`. If it is a `URL` object, it will be automatically converted to an ordinary `options` object.
		
		If both `url` and `options` are specified, the objects are merged, with the`options` properties taking precedence.
		
		The optional `callback` parameter will be added as a one-time listener for
		the `'response'` event.
		
		`http.request()` returns an instance of the {@link ClientRequest} class. The `ClientRequest` instance is a writable stream. If one needs to
		upload a file with a POST request, then write to the `ClientRequest` object.
		
		```js
		const http = require('http');
		
		const postData = JSON.stringify({
		   'msg': 'Hello World!'
		});
		
		const options = {
		   hostname: 'www.google.com',
		   port: 80,
		   path: '/upload',
		   method: 'POST',
		   headers: {
		     'Content-Type': 'application/json',
		     'Content-Length': Buffer.byteLength(postData)
		   }
		};
		
		const req = http.request(options, (res) => {
		   console.log(`STATUS: ${res.statusCode}`);
		   console.log(`HEADERS: ${JSON.stringify(res.headers)}`);
		   res.setEncoding('utf8');
		   res.on('data', (chunk) => {
		     console.log(`BODY: ${chunk}`);
		   });
		   res.on('end', () => {
		     console.log('No more data in response.');
		   });
		});
		
		req.on('error', (e) => {
		   console.error(`problem with request: ${e.message}`);
		});
		
		// Write data to request body
		req.write(postData);
		req.end();
		```
		
		In the example `req.end()` was called. With `http.request()` one
		must always call `req.end()` to signify the end of the request -
		even if there is no data being written to the request body.
		
		If any error is encountered during the request (be that with DNS resolution,
		TCP level errors, or actual HTTP parse errors) an `'error'` event is emitted
		on the returned request object. As with all `'error'` events, if no listeners
		are registered the error will be thrown.
		
		There are a few special headers that should be noted.
		
		* Sending a 'Connection: keep-alive' will notify Node.js that the connection to
		the server should be persisted until the next request.
		* Sending a 'Content-Length' header will disable the default chunked encoding.
		* Sending an 'Expect' header will immediately send the request headers.
		Usually, when sending 'Expect: 100-continue', both a timeout and a listener
		for the `'continue'` event should be set. See RFC 2616 Section 8.2.3 for more
		information.
		* Sending an Authorization header will override using the `auth` option
		to compute basic authentication.
		
		Example using a `URL` as `options`:
		
		```js
		const options = new URL('http://abc:xyz@example.com');
		
		const req = http.request(options, (res) => {
		   // ...
		});
		```
		
		In a successful request, the following events will be emitted in the following
		order:
		
		* `'socket'`
		* `'response'`
		    * `'data'` any number of times, on the `res` object
		    (`'data'` will not be emitted at all if the response body is empty, for
		    instance, in most redirects)
		    * `'end'` on the `res` object
		* `'close'`
		
		In the case of a connection error, the following events will be emitted:
		
		* `'socket'`
		* `'error'`
		* `'close'`
		
		In the case of a premature connection close before the response is received,
		the following events will be emitted in the following order:
		
		* `'socket'`
		* `'error'` with an error with message `'Error: socket hang up'` and code`'ECONNRESET'`
		* `'close'`
		
		In the case of a premature connection close after the response is received,
		the following events will be emitted in the following order:
		
		* `'socket'`
		* `'response'`
		    * `'data'` any number of times, on the `res` object
		* (connection closed here)
		* `'aborted'` on the `res` object
		* `'error'` on the `res` object with an error with message`'Error: aborted'` and code `'ECONNRESET'`.
		* `'close'`
		* `'close'` on the `res` object
		
		If `req.destroy()` is called before a socket is assigned, the following
		events will be emitted in the following order:
		
		* (`req.destroy()` called here)
		* `'error'` with an error with message `'Error: socket hang up'` and code`'ECONNRESET'`
		* `'close'`
		
		If `req.destroy()` is called before the connection succeeds, the following
		events will be emitted in the following order:
		
		* `'socket'`
		* (`req.destroy()` called here)
		* `'error'` with an error with message `'Error: socket hang up'` and code`'ECONNRESET'`
		* `'close'`
		
		If `req.destroy()` is called after the response is received, the following
		events will be emitted in the following order:
		
		* `'socket'`
		* `'response'`
		    * `'data'` any number of times, on the `res` object
		* (`req.destroy()` called here)
		* `'aborted'` on the `res` object
		* `'error'` on the `res` object with an error with message`'Error: aborted'` and code `'ECONNRESET'`.
		* `'close'`
		* `'close'` on the `res` object
		
		If `req.abort()` is called before a socket is assigned, the following
		events will be emitted in the following order:
		
		* (`req.abort()` called here)
		* `'abort'`
		* `'close'`
		
		If `req.abort()` is called before the connection succeeds, the following
		events will be emitted in the following order:
		
		* `'socket'`
		* (`req.abort()` called here)
		* `'abort'`
		* `'error'` with an error with message `'Error: socket hang up'` and code`'ECONNRESET'`
		* `'close'`
		
		If `req.abort()` is called after the response is received, the following
		events will be emitted in the following order:
		
		* `'socket'`
		* `'response'`
		    * `'data'` any number of times, on the `res` object
		* (`req.abort()` called here)
		* `'abort'`
		* `'aborted'` on the `res` object
		* `'error'` on the `res` object with an error with message`'Error: aborted'` and code `'ECONNRESET'`.
		* `'close'`
		* `'close'` on the `res` object
		
		Setting the `timeout` option or using the `setTimeout()` function will
		not abort the request or do anything besides add a `'timeout'` event.
		
		Passing an `AbortSignal` and then calling `abort` on the corresponding`AbortController` will behave the same way as calling `.destroy()` on the
		request itself.
	**/
	@:overload(function(url:ts.AnyOf2<String, node.url.URL>, options:node.http.RequestOptions, ?callback:(res:node.http.IncomingMessage) -> Void):node.http.ClientRequest { })
	static function request(options:ts.AnyOf3<String, node.url.URL, node.http.RequestOptions>, ?callback:(res:node.http.IncomingMessage) -> Void):node.http.ClientRequest;
	/**
		Since most requests are GET requests without bodies, Node.js provides this
		convenience method. The only difference between this method and {@link request} is that it sets the method to GET and calls `req.end()`automatically. The callback must take care to consume the
		response
		data for reasons stated in {@link ClientRequest} section.
		
		The `callback` is invoked with a single argument that is an instance of {@link IncomingMessage}.
		
		JSON fetching example:
		
		```js
		http.get('http://localhost:8000/', (res) => {
		   const { statusCode } = res;
		   const contentType = res.headers['content-type'];
		
		   let error;
		   // Any 2xx status code signals a successful response but
		   // here we're only checking for 200.
		   if (statusCode !== 200) {
		     error = new Error('Request Failed.\n' +
		                       `Status Code: ${statusCode}`);
		   } else if (!/^application\/json/.test(contentType)) {
		     error = new Error('Invalid content-type.\n' +
		                       `Expected application/json but received ${contentType}`);
		   }
		   if (error) {
		     console.error(error.message);
		     // Consume response data to free up memory
		     res.resume();
		     return;
		   }
		
		   res.setEncoding('utf8');
		   let rawData = '';
		   res.on('data', (chunk) => { rawData += chunk; });
		   res.on('end', () => {
		     try {
		       const parsedData = JSON.parse(rawData);
		       console.log(parsedData);
		     } catch (e) {
		       console.error(e.message);
		     }
		   });
		}).on('error', (e) => {
		   console.error(`Got error: ${e.message}`);
		});
		
		// Create a local server to receive data from
		const server = http.createServer((req, res) => {
		   res.writeHead(200, { 'Content-Type': 'application/json' });
		   res.end(JSON.stringify({
		     data: 'Hello World!'
		   }));
		});
		
		server.listen(8000);
		```
	**/
	@:overload(function(url:ts.AnyOf2<String, node.url.URL>, options:node.http.RequestOptions, ?callback:(res:node.http.IncomingMessage) -> Void):node.http.ClientRequest { })
	static function get(options:ts.AnyOf3<String, node.url.URL, node.http.RequestOptions>, ?callback:(res:node.http.IncomingMessage) -> Void):node.http.ClientRequest;
	static final METHODS : Array<String>;
	static final STATUS_CODES : { };
	static var globalAgent : node.http.Agent;
	/**
		Read-only property specifying the maximum allowed size of HTTP headers in bytes.
		Defaults to 16KB. Configurable using the `--max-http-header-size` CLI option.
	**/
	static final maxHeaderSize : Float;
}