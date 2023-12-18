package ts;

/**
	Tuple type implementation generated by dts2hx
**/
@:forward @:forwardStatics extern abstract Tuple6<T0, T1, T2, T3, T4, T5>(std.Array<Any>) from std.Array<Any>
	to std.Array<Any> {
	public inline function new(element0:T0, element1:T1, element2:T2, element3:T3, element4:T4, element5:T5) {
		this = [element0, element1, element2, element3, element4, element5];
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

	public var element3(get, set):T3;

	inline function get_element3():T3
		return cast this[3];

	inline function set_element3(v:T3):T3
		return cast this[3] = cast v;

	public var element4(get, set):T4;

	inline function get_element4():T4
		return cast this[4];

	inline function set_element4(v:T4):T4
		return cast this[4] = cast v;

	public var element5(get, set):T5;

	inline function get_element5():T5
		return cast this[5];

	inline function set_element5(v:T5):T5
		return cast this[5] = cast v;
}
