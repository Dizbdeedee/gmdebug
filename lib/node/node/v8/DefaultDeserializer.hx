package node.v8;

/**
	A subclass of `Deserializer` corresponding to the format written by `DefaultSerializer`.
**/
@:jsRequire("v8", "DefaultDeserializer") extern class DefaultDeserializer extends Deserializer {
	function new();
	static var prototype : DefaultDeserializer;
}