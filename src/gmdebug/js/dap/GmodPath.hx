package gmdebug.js.dap;

import haxe.ds.Option;
import haxe.io.Path as HxPath;
import node.Fs;

abstract GmodPath(String) to String {
	public static function pathToGmodPath(absContext:String, pth:String):Option<GmodPath> {
		var lastind = pth.lastIndexOf(absContext);
		return if (lastind <= -1) {
			trace("*ncp COULD NOT create gmod path");
			None;
		} else {
			var trim = pth.substr(lastind);
			trace('*ncp trimmed $trim');
			Some(cast trim);
		}
	}

	public function createAbs(absContext:String):Option<String> {
		var luapath:String = this;
		var luapath = if (luapath.charAt(0) == "@") {
			luapath.substr(1);
		} else {
			luapath;
		}
		trace('*ncp createAbs $luapath');
		var path = HxPath.join([absContext, luapath]);
		trace('*ncp createAbs attempt $path');
		return if (Fs.existsSync(path)) {
			Some(HxPath.join([absContext, luapath]));
		} else {
			trace("*ncp COULD NOT CREATE ABS - file does not exist");
			None;
		}
	}

	public function createAbsNoCheck(absContext:String):String {
		var luapath:String = this;
		var luapath = if (luapath.charAt(0) == "@") {
			luapath.substr(1);
		} else {
			luapath;
		}
		return HxPath.join([absContext, luapath]);
	}
}
