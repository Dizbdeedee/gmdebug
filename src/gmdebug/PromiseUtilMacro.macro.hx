package gmdebug;

import haxe.macro.Expr.ExprOf;
import haxe.macro.Expr;

class FutureArray_Use {
	public static macro function add(futureArr:ExprOf<Util.FutureArray>, funcCall:Expr) {
		return macro $futureArr._add(gmdebug.PromiseUtil.FutureArray.megaLazy(() -> $funcCall));
	}
}

class PromiseArray_Use {
	public static macro function add(promiseArr:ExprOf<Util.PromiseArray>, funcCall:Expr) {
		return macro $promiseArr._add(Promise.lazy(() -> $funcCall));
	}
}
