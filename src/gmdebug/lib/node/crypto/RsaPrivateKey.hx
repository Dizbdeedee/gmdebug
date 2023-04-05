package node.crypto;

typedef RsaPrivateKey = {
	var key : KeyLike;
	@:optional
	var passphrase : String;
	@:optional
	var oaepHash : String;
	@:optional
	var oaepLabel : global.nodejs.TypedArray;
	@:optional
	var padding : Float;
};