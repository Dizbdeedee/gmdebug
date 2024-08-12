package gmdebug.lua.debugee;

abstract GmodPath(String) to String {
	public static inline function gPath(x:String):GmodPath {
		return cast x;
	}
}
