package js.html;

typedef RTCIceCandidateInit = {
	@:optional
	var candidate : String;
	@:optional
	var sdpMLineIndex : Float;
	@:optional
	var sdpMid : String;
	@:optional
	var usernameFragment : String;
};