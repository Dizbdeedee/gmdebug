package gmdebug.lua.macros;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using Lambda;

class DebugContextMacro {
	static final unmarkedStack = [macro gmdebug.lua.debugcontext.DebugContext.checkUnmarkedStack()];

	public static function build() {
		var fields = Context.getBuildFields();

		for (field in fields) {
			if (field.meta != null) {
				if (field.meta.exists(met -> met.name == ":noCheck")) {
					continue;
				}
			}
			var updatedFieldKind:FieldType = switch [field.access.indexOf(AInline) != -1, field.kind] {
				case [false, FFun(func = {expr: {expr: EBlock(origBlockExpr), pos: origBlockPos}})]:
					var modifiedBlock = unmarkedStack.concat(origBlockExpr);
					func.expr = {expr: EBlock(modifiedBlock), pos: origBlockPos};
					FFun(func);

				// FFun({expr: EBlock(modifiedBlock), pos: origBlockPos});
				default:
					field.kind;
			}
			field.kind = updatedFieldKind;
		}
		return fields;
	}
}
