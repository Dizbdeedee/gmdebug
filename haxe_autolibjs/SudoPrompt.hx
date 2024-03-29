@:jsRequire("sudo-prompt") @valueModuleOnly extern class SudoPrompt {
	static function exec(cmd:String,
		?options:ts.AnyOf5<() -> Void, (error:js.lib.Error) -> Void,
			(error:js.lib.Error, stdout:Dynamic) -> Void,
			(error:js.lib.Error, stdout:Dynamic, stderr:Dynamic) -> Void,
			{@:optional
				var name:String;
				@:optional var icns:String;
				@:optional
				var env:{};
			}>,
		?callback:ts.AnyOf4<() -> Void, (error:js.lib.Error) -> Void,
			(error:js.lib.Error, stdout:Dynamic) -> Void,
			(error:js.lib.Error, stdout:Dynamic, stderr:Dynamic) -> Void>):Void;
}
