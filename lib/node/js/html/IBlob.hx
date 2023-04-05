package js.html;

/**
	A file-like object of immutable, raw data. Blobs represent data that isn't necessarily in a JavaScript-native format. The File interface is based on Blob, inheriting blob functionality and expanding it to support files on the user's system.
**/
typedef IBlob = {
	final size : Float;
	final type : String;
	@:overload(function(?start:Float, ?end:Float, ?contentType:String):js.html.Blob { })
	function slice(?start:Float, ?end:Float, ?contentType:String):js.html.Blob;
	function arrayBuffer():js.lib.Promise<js.lib.ArrayBuffer>;
	function stream():global.nodejs.ReadableStream;
	function text():js.lib.Promise<String>;
};