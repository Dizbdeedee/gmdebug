package js.html;

@:native("AbstractRange") extern class AbstractRange {
	function new();
	/**
		Returns true if range is collapsed, and false otherwise.
	**/
	final collapsed : Bool;
	/**
		Returns range's end node.
	**/
	final endContainer : js.html.Node;
	/**
		Returns range's end offset.
	**/
	final endOffset : Float;
	/**
		Returns range's start node.
	**/
	final startContainer : js.html.Node;
	/**
		Returns range's start offset.
	**/
	final startOffset : Float;
	static var prototype : AbstractRange;
}