package node;

@:jsRequire("node:querystring") @valueModuleOnly extern class NodeQuerystring {
	/**
		The `querystring.stringify()` method produces a URL query string from a
		given `obj` by iterating through the object's "own properties".
		
		It serializes the following types of values passed in `obj`:[&lt;string&gt;](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#String_type) |
		[&lt;number&gt;](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#Number_type) |
		[&lt;bigint&gt;](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt) |
		[&lt;boolean&gt;](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#Boolean_type) |
		[&lt;string\[\]&gt;](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#String_type) |
		[&lt;number\[\]&gt;](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#Number_type) |
		[&lt;bigint\[\]&gt;](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/BigInt) |
		[&lt;boolean\[\]&gt;](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Data_structures#Boolean_type)The numeric values must be finite. Any other input values will be coerced to
		empty strings.
		
		```js
		querystring.stringify({ foo: 'bar', baz: ['qux', 'quux'], corge: '' });
		// Returns 'foo=bar&#x26;baz=qux&#x26;baz=quux&#x26;corge='
		
		querystring.stringify({ foo: 'bar', baz: 'qux' }, ';', ':');
		// Returns 'foo:bar;baz:qux'
		```
		
		By default, characters requiring percent-encoding within the query string will
		be encoded as UTF-8\. If an alternative encoding is required, then an alternative`encodeURIComponent` option will need to be specified:
		
		```js
		// Assuming gbkEncodeURIComponent function already exists,
		
		querystring.stringify({ w: '中文', foo: 'bar' }, null, null,
		                       { encodeURIComponent: gbkEncodeURIComponent });
		```
	**/
	static function stringify(?obj:node.querystring.ParsedUrlQueryInput, ?sep:String, ?eq:String, ?options:node.querystring.StringifyOptions):String;
	/**
		The `querystring.parse()` method parses a URL query string (`str`) into a
		collection of key and value pairs.
		
		For example, the query string `'foo=bar&#x26;abc=xyz&#x26;abc=123'` is parsed into:
		
		```js
		{
		   foo: 'bar',
		   abc: ['xyz', '123']
		}
		```
		
		The object returned by the `querystring.parse()` method _does not_prototypically inherit from the JavaScript `Object`. This means that typical`Object` methods such as `obj.toString()`,
		`obj.hasOwnProperty()`, and others
		are not defined and _will not work_.
		
		By default, percent-encoded characters within the query string will be assumed
		to use UTF-8 encoding. If an alternative character encoding is used, then an
		alternative `decodeURIComponent` option will need to be specified:
		
		```js
		// Assuming gbkDecodeURIComponent function already exists...
		
		querystring.parse('w=%D6%D0%CE%C4&#x26;foo=bar', null, null,
		                   { decodeURIComponent: gbkDecodeURIComponent });
		```
	**/
	static function parse(str:String, ?sep:String, ?eq:String, ?options:node.querystring.ParseOptions):node.querystring.ParsedUrlQuery;
	/**
		The `querystring.escape()` method performs URL percent-encoding on the given`str` in a manner that is optimized for the specific requirements of URL
		query strings.
		
		The `querystring.escape()` method is used by `querystring.stringify()` and is
		generally not expected to be used directly. It is exported primarily to allow
		application code to provide a replacement percent-encoding implementation if
		necessary by assigning `querystring.escape` to an alternative function.
	**/
	static function escape(str:String):String;
	/**
		The `querystring.unescape()` method performs decoding of URL percent-encoded
		characters on the given `str`.
		
		The `querystring.unescape()` method is used by `querystring.parse()` and is
		generally not expected to be used directly. It is exported primarily to allow
		application code to provide a replacement decoding implementation if
		necessary by assigning `querystring.unescape` to an alternative function.
		
		By default, the `querystring.unescape()` method will attempt to use the
		JavaScript built-in `decodeURIComponent()` method to decode. If that fails,
		a safer equivalent that does not throw on malformed URLs will be used.
	**/
	static function unescape(str:String):String;
	/**
		The querystring.encode() function is an alias for querystring.stringify().
	**/
	static function encode(?obj:node.querystring.ParsedUrlQueryInput, ?sep:String, ?eq:String, ?options:node.querystring.StringifyOptions):String;
	/**
		The querystring.decode() function is an alias for querystring.parse().
	**/
	static function decode(str:String, ?sep:String, ?eq:String, ?options:node.querystring.ParseOptions):node.querystring.ParsedUrlQuery;
}