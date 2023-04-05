package js.html;

/**
	This Gamepad API interface represents the pose of a WebVR controller at a given timestamp (which includes orientation, position, velocity, and acceleration information.)
**/
typedef IGamepadPose = {
	final angularAcceleration : Null<js.lib.Float32Array>;
	final angularVelocity : Null<js.lib.Float32Array>;
	final hasOrientation : Bool;
	final hasPosition : Bool;
	final linearAcceleration : Null<js.lib.Float32Array>;
	final linearVelocity : Null<js.lib.Float32Array>;
	final orientation : Null<js.lib.Float32Array>;
	final position : Null<js.lib.Float32Array>;
};