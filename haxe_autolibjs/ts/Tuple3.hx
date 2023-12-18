package ts;

/**
	Tuple type implementation generated by dts2hx
**/
@:forward @:forwardStatics extern abstract Tuple3<T0, T1, T2>(std.Array<Any>) from std.Array<Any>
	to std.Array<Any> {
	public inline function new(element0:T0, element1:T1, element2:T2) {
		this = [element0, element1, element2];
	}

	public var element0(get, set):T0;

	inline function get_element0():T0
		return cast this[0];

	inline function set_element0(v:T0):T0
		return cast this[0] = cast v;

	public var element1(get, set):T1;

	inline function get_element1():T1
		return cast this[1];

	inline function set_element1(v:T1):T1
		return cast this[1] = cast v;

	public var element2(get, set):T2;

	inline function get_element2():T2
		return cast this[2];

	inline function set_element2(v:T2):T2
		return cast this[2] = cast v;
}
