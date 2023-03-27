package js.html;

typedef TransformStreamDefaultController<O> = {
	final desiredSize : Null<Float>;
	function enqueue(chunk:O):Void;
	function error(?reason:Dynamic):Void;
	function terminate():Void;
};