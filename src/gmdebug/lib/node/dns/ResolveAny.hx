package node.dns;

/**
	Uses the DNS protocol to resolve all records (also known as `ANY` or `*` query).
	The `ret` argument passed to the `callback` function will be an array containing
	various types of records. Each object has a property `type` that indicates the
	type of the current record. And depending on the `type`, additional properties
	will be present on the object:

	<omitted>

	Here is an example of the `ret` object passed to the callback:

	```js
	[ { type: 'A', address: '127.0.0.1', ttl: 299 },
	   { type: 'CNAME', value: 'example.com' },
	   { type: 'MX', exchange: 'alt4.aspmx.l.example.com', priority: 50 },
	   { type: 'NS', value: 'ns1.example.com' },
	   { type: 'TXT', entries: [ 'v=spf1 include:_spf.example.com ~all' ] },
	   { type: 'SOA',
		 nsname: 'ns1.example.com',
		 hostmaster: 'admin.example.com',
		 serial: 156696742,
		 refresh: 900,
		 retry: 900,
		 expire: 1800,
		 minttl: 60 } ]
	```

	DNS server operators may choose not to respond to `ANY`queries. It may be better to call individual methods like {@link resolve4},{@link resolveMx}, and so on. For more details, see [RFC
	8482](https://tools.ietf.org/html/rfc8482).
**/
@:jsRequire("dns", "resolveAny") @valueModuleOnly extern class ResolveAny {
	/**
		Uses the DNS protocol to resolve all records (also known as `ANY` or `*` query).
		The `ret` argument passed to the `callback` function will be an array containing
		various types of records. Each object has a property `type` that indicates the
		type of the current record. And depending on the `type`, additional properties
		will be present on the object:

		<omitted>

		Here is an example of the `ret` object passed to the callback:

		```js
		[ { type: 'A', address: '127.0.0.1', ttl: 299 },
		   { type: 'CNAME', value: 'example.com' },
		   { type: 'MX', exchange: 'alt4.aspmx.l.example.com', priority: 50 },
		   { type: 'NS', value: 'ns1.example.com' },
		   { type: 'TXT', entries: [ 'v=spf1 include:_spf.example.com ~all' ] },
		   { type: 'SOA',
			 nsname: 'ns1.example.com',
			 hostmaster: 'admin.example.com',
			 serial: 156696742,
			 refresh: 900,
			 retry: 900,
			 expire: 1800,
			 minttl: 60 } ]
		```

		DNS server operators may choose not to respond to `ANY`queries. It may be better to call individual methods like {@link resolve4},{@link resolveMx}, and so on. For more details, see [RFC
		8482](https://tools.ietf.org/html/rfc8482).
	**/
	@:selfCall
	static function call(hostname:String,
		callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<AnyRecord>) -> Void):Void;
}
