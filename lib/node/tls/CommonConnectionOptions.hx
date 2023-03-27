package node.tls;

typedef CommonConnectionOptions = {
	/**
		An optional TLS context object from tls.createSecureContext()
	**/
	@:optional
	var secureContext : SecureContext;
	/**
		When enabled, TLS packet trace information is written to `stderr`. This can be
		used to debug TLS connection problems.
	**/
	@:optional
	var enableTrace : Bool;
	/**
		If true the server will request a certificate from clients that
		connect and attempt to verify that certificate. Defaults to
		false.
	**/
	@:optional
	var requestCert : Bool;
	/**
		An array of strings or a Buffer naming possible ALPN protocols.
		(Protocols should be ordered by their priority.)
	**/
	@:optional
	var ALPNProtocols : ts.AnyOf3<Array<String>, js.lib.Uint8Array, Array<js.lib.Uint8Array>>;
	/**
		SNICallback(servername, cb) <Function> A function that will be
		called if the client supports SNI TLS extension. Two arguments
		will be passed when called: servername and cb. SNICallback should
		invoke cb(null, ctx), where ctx is a SecureContext instance.
		(tls.createSecureContext(...) can be used to get a proper
		SecureContext.) If SNICallback wasn't provided the default callback
		with high-level API will be used (see below).
	**/
	@:optional
	dynamic function SNICallback(servername:String, cb:ts.AnyOf2<(err:Null<js.lib.Error>) -> Void, (err:Null<js.lib.Error>, ctx:SecureContext) -> Void>):Void;
	/**
		If true the server will reject any connection which is not
		authorized with the list of supplied CAs. This option only has an
		effect if requestCert is true.
	**/
	@:optional
	var rejectUnauthorized : Bool;
};