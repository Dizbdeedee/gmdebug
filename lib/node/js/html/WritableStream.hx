package js.html;

/**
	This Streams API interface provides a standard abstraction for writing streaming data to a destination, known as a sink. This object comes with built-in backpressure and queuing.
**/
@:native("WritableStream") extern class WritableStream<W> {
	function new<W>(?underlyingSink:UnderlyingSink<W>, ?strategy:QueuingStrategy<W>);
	final locked : Bool;
	function abort(?reason:Dynamic):js.lib.Promise<ts.Undefined>;
	function getWriter():WritableStreamDefaultWriter<W>;
	static var prototype : WritableStream<Dynamic>;
}