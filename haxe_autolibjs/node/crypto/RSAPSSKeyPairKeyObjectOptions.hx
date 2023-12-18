package node.crypto;

typedef RSAPSSKeyPairKeyObjectOptions = {
	/**
		Key size in bits
	**/
	var modulusLength:Float;

	@:optional
	var publicExponent:Float;
};
