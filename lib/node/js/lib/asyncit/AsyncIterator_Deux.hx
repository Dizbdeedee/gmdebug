package js.lib.asyncit;

typedef AsyncIterator_Deux<T, TReturn, TNext> = {
	function next(args:haxe.extern.Rest<Any>):js.lib.Promise<IteratorResult<T, TReturn>>;
	@:optional
	@:native("return")
	function return_(?value:ts.AnyOf2<PromiseLike<TReturn>, TReturn>):js.lib.Promise<IteratorResult<T, TReturn>>;
	@:optional
	@:native("throw")
	function throw_(?e:Dynamic):js.lib.Promise<IteratorResult<T, TReturn>>;
};