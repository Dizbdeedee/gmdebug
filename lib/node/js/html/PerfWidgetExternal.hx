package js.html;

@:native("PerfWidgetExternal") extern class PerfWidgetExternal {
	function new();
	final activeNetworkRequestCount : Float;
	final averageFrameTime : Float;
	final averagePaintTime : Float;
	final extraInformationEnabled : Bool;
	final independentRenderingEnabled : Bool;
	final irDisablingContentString : String;
	final irStatusAvailable : Bool;
	final maxCpuSpeed : Float;
	final paintRequestsPerSecond : Float;
	final performanceCounter : Float;
	final performanceCounterFrequency : Float;
	function addEventListener(eventType:String, callback:haxe.Constraints.Function):Void;
	function getMemoryUsage():Float;
	function getProcessCpuUsage():Float;
	function getRecentCpuUsage(last:Null<Float>):Dynamic;
	function getRecentFrames(last:Null<Float>):Dynamic;
	function getRecentMemoryUsage(last:Null<Float>):Dynamic;
	function getRecentPaintRequests(last:Null<Float>):Dynamic;
	function removeEventListener(eventType:String, callback:haxe.Constraints.Function):Void;
	function repositionWindow(x:Float, y:Float):Void;
	function resizeWindow(width:Float, height:Float):Void;
	static var prototype : PerfWidgetExternal;
}