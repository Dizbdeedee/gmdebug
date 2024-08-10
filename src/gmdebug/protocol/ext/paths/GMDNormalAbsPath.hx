package gmdebug.protocol.ext.paths;

import haxe.io.Path as HxPath;

using tink.CoreApi;
using StringTools;

@:forward
abstract GMDNormalAbsPath(String) to String {

	public static function toNormal(pth:String):Option<GMDNormalAbsPath> {
		if (!HxPath.isAbsolute(pth)) {
			return None;
		}
		return Some(toNormalSure(pth));
	}

	public static function toNormalSure(pth:String) {
		var result = HxPath.normalize(pth);
		result = HxPath.removeTrailingSlashes(result);
		//this should fix weirdness with drive letters on windows, and be a no-op on linux. ur.
		#if gmddebug_windows
		var driveChar = result.charAt(0).toLowerCase();
		result = '$driveChar${result.substr(1)}';
		#end
		return cast result;
	}

	public static function toNormalFromRel(pth:String, ?context:String)
		:Outcome<GMDNormalAbsPath,ToNormalFromRelErr> {
		return if (HxPath.isAbsolute(pth)) {
			switch (toNormal(pth)) {
				case Some(res):
					Success(res);
				default:
					Failure(Failure_Miss_1);
			}
		} else {
			var result = HxPath.join([pth,context]);
			if (HxPath.isAbsolute(result)) {
				switch (toNormal(result)) {
					case Some(normal):
						Success(normal);
					case None:
						Failure(Failure_Miss_2);
				}
			} else {
				Failure(Abs_Failure);
			}
		}
	}
}

enum ToNormalFromRelErr {
	Abs_Failure;
	Failure_Miss_1;
	Failure_Miss_2;
}