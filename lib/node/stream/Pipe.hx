package node.stream;

typedef Pipe = {
	function close():Void;
	function hasRef():Bool;
	function ref():Void;
	function unref():Void;
};