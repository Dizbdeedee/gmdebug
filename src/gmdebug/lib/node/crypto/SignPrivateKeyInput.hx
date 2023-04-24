package node.crypto;

typedef SignPrivateKeyInput = {
	var key : ts.AnyOf2<String, node.buffer.Buffer>;
	@:optional
	var format : KeyFormat;
	@:optional
	var type : String;
	@:optional
	var passphrase : ts.AnyOf2<String, node.buffer.Buffer>;
	@:optional
	var padding : Float;
	@:optional
	var saltLength : Float;
	@:optional
	var dsaEncoding : DSAEncoding;
};