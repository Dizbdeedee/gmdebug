package js.html;

@:native("ApplicationCache") extern class ApplicationCache {
	function new();
	@:optional
	dynamic function oncached(ev:js.html.Event):Dynamic;
	@:optional
	dynamic function onchecking(ev:js.html.Event):Dynamic;
	@:optional
	dynamic function ondownloading(ev:js.html.Event):Dynamic;
	@:optional
	dynamic function onerror(ev:js.html.Event):Dynamic;
	@:optional
	dynamic function onnoupdate(ev:js.html.Event):Dynamic;
	@:optional
	dynamic function onobsolete(ev:js.html.Event):Dynamic;
	@:optional
	dynamic function onprogress(ev:ProgressEvent<ApplicationCache>):Dynamic;
	@:optional
	dynamic function onupdateready(ev:js.html.Event):Dynamic;
	final status : Float;
	function abort():Void;
	function swapCache():Void;
	function update():Void;
	final CHECKING : Float;
	final DOWNLOADING : Float;
	final IDLE : Float;
	final OBSOLETE : Float;
	final UNCACHED : Float;
	final UPDATEREADY : Float;
	/**
		Appends an event listener for events whose type attribute value is type. The callback argument sets the callback that will be invoked when the event is dispatched.
		
		The options argument sets listener-specific options. For compatibility this can be a boolean, in which case the method behaves exactly as if the value was specified as options's capture.
		
		When set to true, options's capture prevents callback from being invoked when the event's eventPhase attribute value is BUBBLING_PHASE. When false (or not present), callback will not be invoked when event's eventPhase attribute value is CAPTURING_PHASE. Either way, callback will be invoked if event's eventPhase attribute value is AT_TARGET.
		
		When set to true, options's passive indicates that the callback will not cancel the event by invoking preventDefault(). This is used to enable performance optimizations described in §2.8 Observing event listeners.
		
		When set to true, options's once indicates that the callback will only be invoked once after which the event listener will be removed.
		
		The event listener is appended to target's event listener list and is not appended if it has the same type, callback, and capture.
		
		Appends an event listener for events whose type attribute value is type. The callback argument sets the callback that will be invoked when the event is dispatched.
		
		The options argument sets listener-specific options. For compatibility this can be a boolean, in which case the method behaves exactly as if the value was specified as options's capture.
		
		When set to true, options's capture prevents callback from being invoked when the event's eventPhase attribute value is BUBBLING_PHASE. When false (or not present), callback will not be invoked when event's eventPhase attribute value is CAPTURING_PHASE. Either way, callback will be invoked if event's eventPhase attribute value is AT_TARGET.
		
		When set to true, options's passive indicates that the callback will not cancel the event by invoking preventDefault(). This is used to enable performance optimizations described in §2.8 Observing event listeners.
		
		When set to true, options's once indicates that the callback will only be invoked once after which the event listener will be removed.
		
		The event listener is appended to target's event listener list and is not appended if it has the same type, callback, and capture.
	**/
	@:overload(function(type:String, listener:EventListenerOrEventListenerObject, ?options:ts.AnyOf2<Bool, js.html.AddEventListenerOptions>):Void { })
	function addEventListener<K>(type:K, listener:(ev:Dynamic) -> Dynamic, ?options:ts.AnyOf2<Bool, js.html.AddEventListenerOptions>):Void;
	/**
		Removes the event listener in target's event listener list with the same type, callback, and options.
		
		Removes the event listener in target's event listener list with the same type, callback, and options.
	**/
	@:overload(function(type:String, listener:EventListenerOrEventListenerObject, ?options:ts.AnyOf2<Bool, js.html.EventListenerOptions>):Void { })
	function removeEventListener<K>(type:K, listener:(ev:Dynamic) -> Dynamic, ?options:ts.AnyOf2<Bool, js.html.EventListenerOptions>):Void;
	/**
		Dispatches a synthetic event event to target and returns true if either event's cancelable attribute value is false or its preventDefault() method was not invoked, and false otherwise.
	**/
	function dispatchEvent(event:js.html.Event):Bool;
	static var prototype : ApplicationCache;
	@:native("CHECKING")
	static final CHECKING_ : Float;
	@:native("DOWNLOADING")
	static final DOWNLOADING_ : Float;
	@:native("IDLE")
	static final IDLE_ : Float;
	@:native("OBSOLETE")
	static final OBSOLETE_ : Float;
	@:native("UNCACHED")
	static final UNCACHED_ : Float;
	@:native("UPDATEREADY")
	static final UPDATEREADY_ : Float;
}