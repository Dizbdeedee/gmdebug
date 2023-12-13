package gmdebug.dap.srcds;

import js.node.stream.Writable.IWritable;
import js.node.stream.Readable.IReadable;

using StringTools;

abstract class RedirectBase {
	public final stdin:IWritable;

	public final stdout:IReadable;

	final _stdin:IReadable;

	final _stdout:IWritable;

	var r:Redirector;

	var outputBuffer:Array<String> = [];

	var oldOutput:Array<String> = [];

	var bJustStarted = true;

	var canLoop = true;

	var oldCmdLine:String;

	static function isAllWhitespace(str:String) {
		for (c in str) {
			if (c != " ".code) {
				return false;
			}
		}
		return true;
	}

	static function findLastNotWhitespace(str:String) {
		var retInd = null;
		for (ind => c in str) {
			if (c != " ".code) {
				retInd = ind;
			}
		}
		return retInd;
	}

	public function new(stdin:IWritable, stdout:IReadable, _stdin:IReadable, _stdout:IWritable) {
		this.stdin = stdin;
		this.stdout = stdout;
		this._stdin = _stdin;
		this._stdout = _stdout;
	}
}
