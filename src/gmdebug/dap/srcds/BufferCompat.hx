package gmdebug.dap.srcds;

@:transitive
@:forward
@:forward.variance
@:forwardStatics
abstract BufferCompat(ref_napi.buffer.Buffer._Buffer) from ref_napi.buffer.Buffer._Buffer to ref_napi.buffer.Buffer._Buffer {

    @:to
    public inline function to():global.Buffer {
        return cast this;
    }

    @:from
    public static inline function from(x:global.Buffer):BufferCompat {
        return cast x;
    }

    

}