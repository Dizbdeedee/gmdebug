package ref_struct_di;

/**
	This is the `constructor` of the Struct type that gets returned.
	
	Invoke it with `new` to create a new Buffer instance backing the struct.
	Pass it an existing Buffer instance to use that as the backing buffer.
	Pass in an Object containing the struct fields to auto-populate the
	struct with the data.
**/
typedef StructType = {
	/**
		Pass it an existing Buffer instance to use that as the backing buffer.
	**/
	@:overload(function(?data:{ }):{ } { })
	@:selfCall
	function call(arg:global.Buffer, ?data:{ }):{ };
	var fields : { };
	/**
		Adds a new field to the struct instance with the given name and type.
		Note that this function will throw an Error if any instances of the struct
		type have already been created, therefore this function must be called at the
		beginning, before any instances are created.
	**/
	function defineProperty(name:String, type:ts.AnyOf2<String, ref_napi.Type_>):Void;
	/**
		Custom for struct type instances.
	**/
	function toString():String;
	/**
		The size in bytes required to hold this datatype.
	**/
	var size : Float;
	/**
		The current level of indirection of the buffer.
	**/
	var indirection : Float;
	/**
		To invoke when `ref.get` is invoked on a buffer of this type.
	**/
	function get(buffer:global.Buffer, offset:Float):Dynamic;
	/**
		To invoke when `ref.set` is invoked on a buffer of this type.
	**/
	function set(buffer:global.Buffer, offset:Float, value:Dynamic):Void;
	/**
		The name to use during debugging for this datatype.
	**/
	@:optional
	var name : String;
	/**
		The alignment of this datatype when placed inside a struct.
	**/
	@:optional
	var alignment : Float;
};