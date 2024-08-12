package gmdebug.lua.debugee;

class Start {
	static var debugee:Debugee;

	@:expose("gmddebugDumpSources")
	static function gmddebugDumpSources() {
		debugee.dumpSources();
	}

	public static function main() {
		debugee = new Debugee();
	}
}
