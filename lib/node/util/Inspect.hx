package node.util;

/**
	The `util.inspect()` method returns a string representation of `object` that is
	intended for debugging. The output of `util.inspect` may change at any time
	and should not be depended upon programmatically. Additional `options` may be
	passed that alter the result.`util.inspect()` will use the constructor's name and/or `@@toStringTag` to make
	an identifiable tag for an inspected value.
	
	```js
	class Foo {
	   get [Symbol.toStringTag]() {
	     return 'bar';
	   }
	}
	
	class Bar {}
	
	const baz = Object.create(null, { [Symbol.toStringTag]: { value: 'foo' } });
	
	util.inspect(new Foo()); // 'Foo [bar] {}'
	util.inspect(new Bar()); // 'Bar {}'
	util.inspect(baz);       // '[foo] {}'
	```
	
	Circular references point to their anchor by using a reference index:
	
	```js
	const { inspect } = require('util');
	
	const obj = {};
	obj.a = [obj];
	obj.b = {};
	obj.b.inner = obj.b;
	obj.b.obj = obj;
	
	console.log(inspect(obj));
	// <ref *1> {
	//   a: [ [Circular *1] ],
	//   b: <ref *2> { inner: [Circular *2], obj: [Circular *1] }
	// }
	```
	
	The following example inspects all properties of the `util` object:
	
	```js
	const util = require('util');
	
	console.log(util.inspect(util, { showHidden: true, depth: null }));
	```
	
	The following example highlights the effect of the `compact` option:
	
	```js
	const util = require('util');
	
	const o = {
	   a: [1, 2, [[
	     'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit, sed do ' +
	       'eiusmod \ntempor incididunt ut labore et dolore magna aliqua.',
	     'test',
	     'foo']], 4],
	   b: new Map([['za', 1], ['zb', 'test']])
	};
	console.log(util.inspect(o, { compact: true, depth: 5, breakLength: 80 }));
	
	// { a:
	//   [ 1,
	//     2,
	//     [ [ 'Lorem ipsum dolor sit amet,\nconsectetur [...]', // A long line
	//           'test',
	//           'foo' ] ],
	//     4 ],
	//   b: Map(2) { 'za' => 1, 'zb' => 'test' } }
	
	// Setting `compact` to false or an integer creates more reader friendly output.
	console.log(util.inspect(o, { compact: false, depth: 5, breakLength: 80 }));
	
	// {
	//   a: [
	//     1,
	//     2,
	//     [
	//       [
	//         'Lorem ipsum dolor sit amet,\n' +
	//           'consectetur adipiscing elit, sed do eiusmod \n' +
	//           'tempor incididunt ut labore et dolore magna aliqua.',
	//         'test',
	//         'foo'
	//       ]
	//     ],
	//     4
	//   ],
	//   b: Map(2) {
	//     'za' => 1,
	//     'zb' => 'test'
	//   }
	// }
	
	// Setting `breakLength` to e.g. 150 will print the "Lorem ipsum" text in a
	// single line.
	```
	
	The `showHidden` option allows [`WeakMap`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap) and
	[`WeakSet`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet) entries to be
	inspected. If there are more entries than `maxArrayLength`, there is no
	guarantee which entries are displayed. That means retrieving the same[`WeakSet`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet) entries twice may
	result in different output. Furthermore, entries
	with no remaining strong references may be garbage collected at any time.
	
	```js
	const { inspect } = require('util');
	
	const obj = { a: 1 };
	const obj2 = { b: 2 };
	const weakSet = new WeakSet([obj, obj2]);
	
	console.log(inspect(weakSet, { showHidden: true }));
	// WeakSet { { a: 1 }, { b: 2 } }
	```
	
	The `sorted` option ensures that an object's property insertion order does not
	impact the result of `util.inspect()`.
	
	```js
	const { inspect } = require('util');
	const assert = require('assert');
	
	const o1 = {
	   b: [2, 3, 1],
	   a: '`a` comes before `b`',
	   c: new Set([2, 3, 1])
	};
	console.log(inspect(o1, { sorted: true }));
	// { a: '`a` comes before `b`', b: [ 2, 3, 1 ], c: Set(3) { 1, 2, 3 } }
	console.log(inspect(o1, { sorted: (a, b) => b.localeCompare(a) }));
	// { c: Set(3) { 3, 2, 1 }, b: [ 2, 3, 1 ], a: '`a` comes before `b`' }
	
	const o2 = {
	   c: new Set([2, 1, 3]),
	   a: '`a` comes before `b`',
	   b: [2, 3, 1]
	};
	assert.strict.equal(
	   inspect(o1, { sorted: true }),
	   inspect(o2, { sorted: true })
	);
	```
	
	`util.inspect()` is a synchronous method intended for debugging. Its maximum
	output length is approximately 128 MB. Inputs that result in longer output will
	be truncated.
**/
@:jsRequire("util", "inspect") @valueModuleOnly extern class Inspect {
	/**
		The `util.inspect()` method returns a string representation of `object` that is
		intended for debugging. The output of `util.inspect` may change at any time
		and should not be depended upon programmatically. Additional `options` may be
		passed that alter the result.`util.inspect()` will use the constructor's name and/or `@@toStringTag` to make
		an identifiable tag for an inspected value.
		
		```js
		class Foo {
		   get [Symbol.toStringTag]() {
		     return 'bar';
		   }
		}
		
		class Bar {}
		
		const baz = Object.create(null, { [Symbol.toStringTag]: { value: 'foo' } });
		
		util.inspect(new Foo()); // 'Foo [bar] {}'
		util.inspect(new Bar()); // 'Bar {}'
		util.inspect(baz);       // '[foo] {}'
		```
		
		Circular references point to their anchor by using a reference index:
		
		```js
		const { inspect } = require('util');
		
		const obj = {};
		obj.a = [obj];
		obj.b = {};
		obj.b.inner = obj.b;
		obj.b.obj = obj;
		
		console.log(inspect(obj));
		// <ref *1> {
		//   a: [ [Circular *1] ],
		//   b: <ref *2> { inner: [Circular *2], obj: [Circular *1] }
		// }
		```
		
		The following example inspects all properties of the `util` object:
		
		```js
		const util = require('util');
		
		console.log(util.inspect(util, { showHidden: true, depth: null }));
		```
		
		The following example highlights the effect of the `compact` option:
		
		```js
		const util = require('util');
		
		const o = {
		   a: [1, 2, [[
		     'Lorem ipsum dolor sit amet,\nconsectetur adipiscing elit, sed do ' +
		       'eiusmod \ntempor incididunt ut labore et dolore magna aliqua.',
		     'test',
		     'foo']], 4],
		   b: new Map([['za', 1], ['zb', 'test']])
		};
		console.log(util.inspect(o, { compact: true, depth: 5, breakLength: 80 }));
		
		// { a:
		//   [ 1,
		//     2,
		//     [ [ 'Lorem ipsum dolor sit amet,\nconsectetur [...]', // A long line
		//           'test',
		//           'foo' ] ],
		//     4 ],
		//   b: Map(2) { 'za' => 1, 'zb' => 'test' } }
		
		// Setting `compact` to false or an integer creates more reader friendly output.
		console.log(util.inspect(o, { compact: false, depth: 5, breakLength: 80 }));
		
		// {
		//   a: [
		//     1,
		//     2,
		//     [
		//       [
		//         'Lorem ipsum dolor sit amet,\n' +
		//           'consectetur adipiscing elit, sed do eiusmod \n' +
		//           'tempor incididunt ut labore et dolore magna aliqua.',
		//         'test',
		//         'foo'
		//       ]
		//     ],
		//     4
		//   ],
		//   b: Map(2) {
		//     'za' => 1,
		//     'zb' => 'test'
		//   }
		// }
		
		// Setting `breakLength` to e.g. 150 will print the "Lorem ipsum" text in a
		// single line.
		```
		
		The `showHidden` option allows [`WeakMap`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap) and
		[`WeakSet`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet) entries to be
		inspected. If there are more entries than `maxArrayLength`, there is no
		guarantee which entries are displayed. That means retrieving the same[`WeakSet`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakSet) entries twice may
		result in different output. Furthermore, entries
		with no remaining strong references may be garbage collected at any time.
		
		```js
		const { inspect } = require('util');
		
		const obj = { a: 1 };
		const obj2 = { b: 2 };
		const weakSet = new WeakSet([obj, obj2]);
		
		console.log(inspect(weakSet, { showHidden: true }));
		// WeakSet { { a: 1 }, { b: 2 } }
		```
		
		The `sorted` option ensures that an object's property insertion order does not
		impact the result of `util.inspect()`.
		
		```js
		const { inspect } = require('util');
		const assert = require('assert');
		
		const o1 = {
		   b: [2, 3, 1],
		   a: '`a` comes before `b`',
		   c: new Set([2, 3, 1])
		};
		console.log(inspect(o1, { sorted: true }));
		// { a: '`a` comes before `b`', b: [ 2, 3, 1 ], c: Set(3) { 1, 2, 3 } }
		console.log(inspect(o1, { sorted: (a, b) => b.localeCompare(a) }));
		// { c: Set(3) { 3, 2, 1 }, b: [ 2, 3, 1 ], a: '`a` comes before `b`' }
		
		const o2 = {
		   c: new Set([2, 1, 3]),
		   a: '`a` comes before `b`',
		   b: [2, 3, 1]
		};
		assert.strict.equal(
		   inspect(o1, { sorted: true }),
		   inspect(o2, { sorted: true })
		);
		```
		
		`util.inspect()` is a synchronous method intended for debugging. Its maximum
		output length is approximately 128 MB. Inputs that result in longer output will
		be truncated.
	**/
	@:overload(function(object:Dynamic, options:InspectOptions):String { })
	@:selfCall
	static function call(object:Dynamic, ?showHidden:Bool, ?depth:Float, ?color:Bool):String;
	static var colors : global.nodejs.Dict<ts.Tuple2<Float, Float>>;
	static var styles : Dynamic;
	static var defaultOptions : InspectOptions;
	/**
		Allows changing inspect settings from the repl.
	**/
	static var replDefaults : InspectOptions;
	static final custom : js.lib.Symbol;
}