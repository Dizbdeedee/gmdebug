package gmdebug;

using tink.CoreApi;

@:using(PromiseUtilMacro.FutureArray_Use)
abstract FutureArray<T>(Array<Future<T>>) {
	public function new() {
		this = [];
	}

	@:noCompletion
	public inline function _add(x:Dynamic) {
		return this.push(x);
	}

	public inline static function megaLazy<X>(l:Lazy<Future<X>>) {
		return new Future(cb -> l.get()
			.handle(cb));
	}

	public inline function inSequence():Future<Array<T>> {
		return Future.inSequence(this);
	}

	public inline function inParallel(threads:Int):Future<Array<T>> {
		return Future.inParallel(this, threads);
	}
}

@:using(PromiseUtilMacro.PromiseArray_Use)
abstract PromiseArray<T>(Array<Promise<T>>) {
	public function new() {
		this = [];
	}

	@:noCompletion
	public inline function _add(x:Dynamic) {
		return this.push(x);
	}

	// public static function mapIntoPromises<X,T>(arr:Array<X>,transform:X -> T):PromiseArray<T> {
	//     var newArr = [];
	//     for (i in arr) {
	//         newArr.push(Promise.lazy(() -> transform(i)));
	//     }
	//     return cast newArr;
	// }

	public inline function inSequence():Promise<Array<T>> {
		return Promise.inSequence(this);
	}

	public inline function inParallel(threads:Int):Promise<Array<T>> {
		return Promise.inParallel(this, threads);
	}
}
