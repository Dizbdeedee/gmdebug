package node.dns;

/**
	Uses the DNS protocol to resolve a host name (e.g. `'nodejs.org'`) into an array
	of the resource records. The `callback` function has arguments`(err, records)`. When successful, `records` will be an array of resource
	records. The type and structure of individual results varies based on `rrtype`:
	
	<omitted>
	
	On error, `err` is an `Error` object, where `err.code` is one of the `DNS error codes`.
**/
@:jsRequire("dns", "resolve") @valueModuleOnly extern class Resolve {
	/**
		Uses the DNS protocol to resolve a host name (e.g. `'nodejs.org'`) into an array
		of the resource records. The `callback` function has arguments`(err, records)`. When successful, `records` will be an array of resource
		records. The type and structure of individual results varies based on `rrtype`:
		
		<omitted>
		
		On error, `err` is an `Error` object, where `err.code` is one of the `DNS error codes`.
	**/
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<String>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<String>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<AnyRecord>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<String>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<MxRecord>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<NaptrRecord>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<String>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<String>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:SoaRecord) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<SrvRecord>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<Array<String>>) -> Void):Void { })
	@:overload(function(hostname:String, rrtype:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:ts.AnyOf7<Array<String>, SoaRecord, Array<AnyRecord>, Array<MxRecord>, Array<NaptrRecord>, Array<SrvRecord>, Array<Array<String>>>) -> Void):Void { })
	@:selfCall
	static function call(hostname:String, callback:(err:Null<global.nodejs.ErrnoException>, addresses:Array<String>) -> Void):Void;
}